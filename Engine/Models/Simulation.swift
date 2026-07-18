public final class Simulation {
    // Immutable inputs.
    public let catalog: ContentCatalog
    public let level: LevelDefinition

    // Mutable run state.
    public private(set) var time: Double = 0
    public private(set) var tick: Int = 0
    public private(set) var gold: Int
    public private(set) var lives: Int
    public private(set) var enemies: ContiguousArray<Enemy> = []
    public private(set) var towers: [Tower?]
    public private(set) var outcome: Outcome?

    // Counters.
    public private(set) var killed = 0
    public private(set) var routed = 0
    public private(set) var captured = 0
    public private(set) var leaked = 0
    public private(set) var fatesByType: [[Int]]   // [enemyTypeIndex][EnemyFate]
    public private(set) var goldEarned = 0
    /// Per-wave max progress fraction any enemy reached (the tension trace /
    /// flatness detector: a wave that never crosses ~0.6 will bore humans too).
    public private(set) var waveMaxProgress: [Double]

    private var policy: any CommanderPolicy
    private var observers: [SimulationObserver] = []

    // RNG streams (see SeededRNG.fork for why they're separate).
    private var rngCombat: SeededRNG
    private var rngMorale: SeededRNG
    private var rngContagion: SeededRNG

    // Precomputed spawn timeline.
    private struct ScheduledSpawn {
        var time: Double
        var enemyTypeIndex: Int
        var pathIndex: Int
        var waveIndex: Int
    }
    private var schedule: [ScheduledSpawn] = []
    private var scheduleCursor = 0
    private var lastWaveAnnounced = -1
    private var nextSpawnID = 0

    // Scratch buffers, rebuilt each tick (kept as stored properties so their
    // capacity is reused instead of reallocated).
    private var positions: [Point] = []
    private var moraleRegen: [Double] = []
    private var disciplineBonus: [Double] = []
    private var contagionAccumulator: Double = 0

    // MARK: - Init

    public init(
        level: LevelDefinition,
        catalog: ContentCatalog,
        policy: any CommanderPolicy,
        seed: UInt64
    ) throws {
        self.level = level
        self.catalog = catalog
        self.policy = policy
        self.gold = level.startingGold
        self.lives = level.lives
        self.towers = Array(repeating: nil, count: level.slots.count)
        self.fatesByType = Array(
            repeating: [0, 0, 0, 0],
            count: catalog.enemyTypes.count
        )
        self.waveMaxProgress = Array(repeating: 0, count: level.waves.count)

        let root = SeededRNG(seed: seed)
        self.rngCombat = root.fork(stream: 1)
        self.rngMorale = root.fork(stream: 2)
        self.rngContagion = root.fork(stream: 3)

        // Flatten the wave timeline once, up front.
        var sched: [ScheduledSpawn] = []
        for (wi, wave) in level.waves.enumerated() {
            for entry in wave.spawns {
                let typeIndex = try catalog.requireEnemyIndex(id: entry.enemyTypeID)
                guard entry.pathIndex >= 0, entry.pathIndex < level.paths.count else {
                    throw SimulationError.badPathIndex(entry.pathIndex, level: level.id)
                }
                for k in 0..<entry.count {
                    sched.append(ScheduledSpawn(
                        time: wave.startTime + entry.delay + Double(k) * entry.interval,
                        enemyTypeIndex: typeIndex,
                        pathIndex: entry.pathIndex,
                        waveIndex: wi
                    ))
                }
            }
        }
        // Stable sort: ties resolve by insertion order, keeping runs identical
        // across content edits that don't change timings.
        self.schedule = sched.enumerated()
            .sorted { ($0.element.time, $0.offset) < ($1.element.time, $1.offset) }
            .map { $0.element }
    }

    public enum SimulationError: Error, CustomStringConvertible {
        case badPathIndex(Int, level: String)

        public var description: String {
            switch self {
            case let .badPathIndex(i, level):
                return "Level '\(level)' references path index \(i) which does not exist"
            }
        }
    }

    public func addObserver(_ o: SimulationObserver) {
        observers.append(o)
    }

    private func emit(_ e: SimEvent) {
        guard !observers.isEmpty else { return }
        for o in observers { o.handle(e, atTime: time) }
    }

    // MARK: - Build API (called by policies)

    @discardableResult
    public func build(slot: Int, towerID: String) -> BuildResult {
        guard slot >= 0, slot < towers.count, towers[slot] == nil,
              let typeIndex = catalog.towerIndex(id: towerID),
              let first = catalog.towerTypes[typeIndex].levels.first
        else { return .invalid }
        guard gold >= first.cost else { return .needGold }
        gold -= first.cost
        towers[slot] = Tower(typeIndex: typeIndex, slotIndex: slot)
        emit(.towerBuilt(slot: slot, towerID: towerID))
        return .ok
    }

    @discardableResult
    public func upgrade(slot: Int) -> BuildResult {
        guard slot >= 0, slot < towers.count, var tower = towers[slot] else { return .invalid }
        let type = catalog.towerTypes[tower.typeIndex]
        let nextLevel = tower.level + 1
        guard nextLevel < type.levels.count else { return .invalid }
        let cost = type.levels[nextLevel].cost
        guard gold >= cost else { return .needGold }
        gold -= cost
        tower.level = nextLevel
        towers[slot] = tower
        emit(.towerUpgraded(slot: slot, level: nextLevel))
        return .ok
    }

    // MARK: - Run

    /// Runs to completion (or the safety cap) and reports.
    public func run(maxSeconds: Double = 900) -> SimulationResult {
        while outcome == nil, time < maxSeconds {
            step()
        }
        if outcome == nil { outcome = .timeout }
        return makeResult()
    }

    // MARK: - Tick

    public func step() {
        guard outcome == nil else { return }
        let dt = SimClock.dt

        // 1. Policy.
        policy.tick(time: time, sim: self)

        // 2. Spawns.
        while scheduleCursor < schedule.count, schedule[scheduleCursor].time <= time {
            let s = schedule[scheduleCursor]
            scheduleCursor += 1
            if s.waveIndex > lastWaveAnnounced {
                lastWaveAnnounced = s.waveIndex
                emit(.waveStarted(index: s.waveIndex))
            }
            let type = catalog.enemyTypes[s.enemyTypeIndex]
            let threshold = Tunables.moraleMax
                * rngMorale.double(in: type.stats.breakBand)
            let enemy = Enemy(
                spawnID: nextSpawnID,
                typeIndex: s.enemyTypeIndex,
                waveIndex: s.waveIndex,
                pathIndex: s.pathIndex,
                type: type,
                shakenThreshold: threshold
            )
            nextSpawnID += 1
            enemies.append(enemy)
            emit(.enemySpawned(spawnID: enemy.spawnID, typeID: type.id))
        }

        let n = enemies.count
        if n > 0 {
            // 3. Position cache.
            positions.removeAll(keepingCapacity: true)
            positions.reserveCapacity(n)
            for i in 0..<n {
                let path = level.paths[enemies[i].pathIndex]
                positions.append(path.point(atDistance: enemies[i].distance))
            }

            // 4. Auras.
            moraleRegen.removeAll(keepingCapacity: true)
            disciplineBonus.removeAll(keepingCapacity: true)
            for _ in 0..<n {
                moraleRegen.append(Tunables.baseMoraleRegenPerSecond)
                disciplineBonus.append(0)
            }
            for i in 0..<n where !enemies[i].removed {
                for trait in catalog.enemyTypes[enemies[i].typeIndex].traits {
                    switch trait {
                    case let .rallyBeat(radius, rate):
                        let r2 = radius * radius
                        for j in 0..<n where j != i && !enemies[j].removed {
                            if positions[i].squaredDistance(to: positions[j]) <= r2 {
                                moraleRegen[j] += rate
                            }
                        }
                    case let .commandAura(radius, bonus, _):
                        let r2 = radius * radius
                        for j in 0..<n where j != i && !enemies[j].removed {
                            if positions[i].squaredDistance(to: positions[j]) <= r2 {
                                disciplineBonus[j] = max(disciplineBonus[j], bonus)
                            }
                        }
                    default:
                        break
                    }
                }
            }

            // 5. Towers fire.
            for slot in 0..<towers.count {
                guard var tower = towers[slot] else { continue }
                tower.cooldown -= dt
                if tower.cooldown <= 0 {
                    let type = catalog.towerTypes[tower.typeIndex]
                    let lvl = type.levels[tower.level]
                    if let target = selectTarget(
                        from: level.slots[slot].position,
                        range: lvl.range,
                        targeting: lvl.targeting
                    ) {
                        fire(level: lvl, at: target)
                        tower.cooldown = lvl.fireInterval
                    }
                }
                towers[slot] = tower
            }

            // 6. Contagion.
            contagionAccumulator += dt
            if contagionAccumulator >= Tunables.contagionTickInterval {
                contagionAccumulator -= Tunables.contagionTickInterval
                contagionTick(interval: Tunables.contagionTickInterval)
            }

            // 7. Morale resolution (with break cascades).
            resolveMorale(dt: dt)

            // 8. Movement & exits.
            for i in 0..<enemies.count where !enemies[i].removed {
                var e = enemies[i]
                let stats = catalog.enemyTypes[e.typeIndex].stats
                let path = level.paths[e.pathIndex]
                switch e.state {
                case .broken:
                    e.distance -= stats.speed * Tunables.routSpeedMultiplier * dt
                    if e.distance <= 0 {
                        remove(&e, fate: .routed)
                    }
                case .shaken, .steady:
                    let mult = (e.state == .shaken) ? Tunables.shakenSpeedMultiplier : 1.0
                    e.distance += stats.speed * mult * dt
                    let progress = e.distance / path.totalLength
                    if progress > waveMaxProgress[e.waveIndex] {
                        waveMaxProgress[e.waveIndex] = min(progress, 1.0)
                    }
                    if e.distance >= path.totalLength {
                        lives -= stats.livesCost
                        remove(&e, fate: .leaked)
                    }
                }
                enemies[i] = e
            }
        }

        // 9. Compaction (order-preserving, for determinism you can read).
        if enemies.contains(where: { $0.removed }) {
            enemies = ContiguousArray(enemies.filter { !$0.removed })
        }

        // 10. End conditions.
        if lives <= 0 {
            outcome = .defeat
        } else if scheduleCursor == schedule.count && enemies.isEmpty {
            outcome = .victory
        }

        time += dt
        tick += 1
    }

    // MARK: - Targeting & damage

    private func selectTarget(from origin: Point, range: Double, targeting: Targeting) -> Int? {
        let r2 = range * range
        var best: Int? = nil
        var bestKey = -Double.infinity
        for i in 0..<enemies.count where !enemies[i].removed {
            guard positions[i].squaredDistance(to: origin) <= r2 else { continue }
            let e = enemies[i]
            let key: Double
            switch targeting {
            case .first: key = e.distance
            case .last: key = -e.distance
            case .strongest: key = e.hp
            case .shakiest:
                // Prefer units that can still be broken; already-Broken units
                // rank behind everything else.
                key = e.state == .broken ? -1_000_000 : -e.morale
            }
            if key > bestKey {
                bestKey = key
                best = i
            }
        }
        return best
    }

    private func fire(level lvl: TowerLevel, at primary: Int) {
        if lvl.aoeRadius > 0 {
            let center = positions[primary]
            let r2 = lvl.aoeRadius * lvl.aoeRadius
            for i in 0..<enemies.count where !enemies[i].removed {
                if positions[i].squaredDistance(to: center) <= r2 {
                    applyVolley(lvl, to: i, isPrimary: i == primary)
                }
            }
        } else {
            applyVolley(lvl, to: primary, isPrimary: true)
        }
    }

    private func applyVolley(_ lvl: TowerLevel, to index: Int, isPrimary: Bool) {
        var e = enemies[index]
        guard !e.removed else { return }
        let stats = catalog.enemyTypes[e.typeIndex].stats

        // Shot vs cover.
        if lvl.shotMax > 0 {
            let roll = rngCombat.double(in: lvl.shotMin...lvl.shotMax)
            e.hp -= roll * (1.0 - stats.cover)
        }

        // Terror vs discipline (aura bonus caps at full immunity).
        if lvl.terrorMax > 0 {
            let effDiscipline = min(1.0, stats.discipline + disciplineBonus[index])
            if effDiscipline < 1.0 {
                let roll = rngCombat.double(in: lvl.terrorMin...lvl.terrorMax)
                e.morale -= roll * (1.0 - effDiscipline)
            }
        }

        // Contagion application (primary target only) vs hardiness.
        if isPrimary, lvl.contagionChance > 0, !e.infected {
            if rngCombat.chance(lvl.contagionChance * (1.0 - stats.hardiness)) {
                e.infected = true
            }
        }

        if e.hp <= 0 {
            kill(&e)
        }
        enemies[index] = e
    }

    // MARK: - Contagion

    private func contagionTick(interval: Double) {
        let n = enemies.count
        // Drain phase: HP down to the floor, then morale pressure instead.
        for i in 0..<n where !enemies[i].removed && enemies[i].infected {
            var e = enemies[i]
            let stats = catalog.enemyTypes[e.typeIndex].stats
            let floor = stats.maxHP * Tunables.diseaseHPFloorFraction
            if e.hp > floor {
                e.hp = max(floor, e.hp - Tunables.diseaseHPPerSecond * interval)
            } else {
                let effDiscipline = min(1.0, stats.discipline + disciplineBonus[i])
                if effDiscipline < 1.0 {
                    e.morale -= Tunables.diseaseMoralePerSecond * interval * (1.0 - effDiscipline)
                }
            }
            enemies[i] = e
        }
        // Spread phase: proximity transmission. Slows clump enemies; clumped
        // enemies infect each other faster — the epidemic-amplifier interaction.
        let r2 = Tunables.contagionSpreadRadius * Tunables.contagionSpreadRadius
        for i in 0..<n where !enemies[i].removed && enemies[i].infected {
            for j in 0..<n where j != i && !enemies[j].removed && !enemies[j].infected {
                guard positions[i].squaredDistance(to: positions[j]) <= r2 else { continue }
                let hardiness = catalog.enemyTypes[enemies[j].typeIndex].stats.hardiness
                if rngContagion.chance(Tunables.contagionSpreadChance * (1.0 - hardiness)) {
                    enemies[j].infected = true
                }
            }
        }
    }

    // MARK: - Morale

    private func resolveMorale(dt: Double) {
        let n = enemies.count

        // Regen and Shaken transitions.
        for i in 0..<n where !enemies[i].removed {
            var e = enemies[i]
            if e.state != .broken {
                e.morale = min(Tunables.moraleMax, e.morale + moraleRegen[i] * dt)
                let stats = catalog.enemyTypes[e.typeIndex].stats
                let steadyGate = e.isSteadyAdvance
                    && e.hp > stats.maxHP * Tunables.steadyAdvanceHPGate
                if e.state == .steady, e.morale <= e.shakenThreshold, !steadyGate {
                    e.state = .shaken
                } else if e.state == .shaken, e.morale > e.shakenThreshold {
                    e.state = .steady   // rallied back above threshold
                }
            }
            enemies[i] = e
        }

        // Break cascade: breaking units splash morale damage, which can break
        // neighbours in the same tick — iterate until quiescent. Bounded by n.
        var anyBroke = true
        while anyBroke {
            anyBroke = false
            for i in 0..<n where !enemies[i].removed {
                var e = enemies[i]
                guard e.state != .broken, e.morale <= 0 else { continue }
                anyBroke = true
                e.state = .broken

                // Splash to neighbours.
                let mult = e.isWavering ? Tunables.waveringSplashMultiplier : 1.0
                let splash = Tunables.breakMoraleSplash * mult
                let r2 = Tunables.breakSplashRadius * Tunables.breakSplashRadius
                for j in 0..<n where j != i && !enemies[j].removed && enemies[j].state != .broken {
                    guard positions[i].squaredDistance(to: positions[j]) <= r2 else { continue }
                    let stats = catalog.enemyTypes[enemies[j].typeIndex].stats
                    let effDiscipline = min(1.0, stats.discipline + disciplineBonus[j])
                    enemies[j].morale -= splash * (1.0 - effDiscipline)
                }

                // Mercenaries surrender on the spot rather than routing.
                if e.isMercenary {
                    remove(&e, fate: .captured)
                }
                enemies[i] = e
            }
        }
    }

    // MARK: - Removal & economy

    private func kill(_ e: inout Enemy) {
        // Killing a routing unit still pays full — finishing routers is the
        // sharpshooter's payoff.
        remove(&e, fate: .killed)
    }

    private func remove(_ e: inout Enemy, fate: EnemyFate) {
        guard !e.removed else { return }
        e.removed = true
        let type = catalog.enemyTypes[e.typeIndex]
        let base = Double(type.stats.gold)
        let earned: Int
        switch fate {
        case .killed:
            killed += 1
            earned = Int((base * Tunables.killBountyMultiplier).rounded())
        case .routed:
            routed += 1
            earned = Int((base * Tunables.routBountyMultiplier).rounded())
        case .captured:
            captured += 1
            earned = Int((base * Tunables.captureBountyMultiplier).rounded())
        case .leaked:
            leaked += 1
            earned = 0
        }
        gold += earned
        goldEarned += earned
        fatesByType[e.typeIndex][fateIndex(fate)] += 1

        // Command aura holders shock their own side when they fall.
        for trait in type.traits {
            if case let .commandAura(radius, _, deathShock) = trait, fate == .killed {
                deathShockSplash(around: e, radius: radius, amount: deathShock)
            }
        }
        emit(.enemyRemoved(spawnID: e.spawnID, typeID: type.id, fate: fate))
    }

    private func deathShockSplash(around e: Enemy, radius: Double, amount: Double) {
        guard let origin = positionOf(e) else { return }
        let r2 = radius * radius
        for j in 0..<enemies.count where !enemies[j].removed && enemies[j].state != .broken {
            guard j < positions.count else { continue }
            guard positions[j].squaredDistance(to: origin) <= r2 else { continue }
            let stats = catalog.enemyTypes[enemies[j].typeIndex].stats
            let effDiscipline = min(1.0, stats.discipline + disciplineBonus[j])
            enemies[j].morale -= amount * (1.0 - effDiscipline)
        }
    }

    private func positionOf(_ e: Enemy) -> Point? {
        guard e.pathIndex < level.paths.count else { return nil }
        return level.paths[e.pathIndex].point(atDistance: e.distance)
    }

    private func fateIndex(_ f: EnemyFate) -> Int {
        switch f {
        case .killed: return 0
        case .routed: return 1
        case .captured: return 2
        case .leaked: return 3
        }
    }

    // MARK: - Result

    private func makeResult() -> SimulationResult {
        var perType: [String: SimulationResult.TypeFates] = [:]
        for (i, type) in catalog.enemyTypes.enumerated() {
            let f = fatesByType[i]
            if f[0] + f[1] + f[2] + f[3] > 0 {
                perType[type.id] = SimulationResult.TypeFates(
                    killed: f[0], routed: f[1], captured: f[2], leaked: f[3]
                )
            }
        }
        return SimulationResult(
            outcome: outcome ?? .timeout,
            seconds: time,
            livesRemaining: max(0, lives),
            goldRemaining: gold,
            goldEarned: goldEarned,
            killed: killed,
            routed: routed,
            captured: captured,
            leaked: leaked,
            fatesByTypeID: perType,
            waveMaxProgress: waveMaxProgress
        )
    }
}
