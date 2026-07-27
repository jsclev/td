import Foundation
import CoreGraphics
import Combine
import QuartzCore

/// The four tower archetypes (a fifth is anticipated — all layout and menu
/// code derives from `allCases.count`, so adding a case Just Works).
enum TowerKind: String, CaseIterable, Identifiable {
    case ranged
    case melee
    case artillery
    case magic

    var id: String { rawValue }

    /// Short label under the build-menu icon.
    var label: String {
        switch self {
        case .ranged: return "Ranged"
        case .melee: return "Melee"
        case .artillery: return "Artillery"
        case .magic: return "Magic"
        }
    }

    /// Asset-catalog sprite for the built tower. Nil until the tower kind has
    /// art (magic doesn't yet).
    var assetName: String? {
        switch self {
        case .ranged: return "minuteman_post"
        case .melee: return "militia_barracks"
        case .artillery: return "field_cannon"
        case .magic: return nil
        }
    }

    /// SF Symbol shown in the build menu for kinds without sprite art.
    var symbolName: String {
        switch self {
        case .ranged: return "scope"
        case .melee: return "shield.fill"
        case .artillery: return "burst.fill"
        case .magic: return "sparkles"
        }
    }

    /// Gold cost to upgrade a tower of this kind TO the given level.
    /// Placeholder numbers that live in Swift, not the database — tower stats
    /// stay code-side while balance is tuned in the simulator; only the
    /// per-level unlock caps are data. Level 3 ranged is the riflemen tier.
    func upgradeCost(to level: Int) -> Int? {
        let costs: [Int: Int]
        switch self {
        case .ranged: costs = [2: 90, 3: 130]
        case .melee: costs = [2: 120]
        case .artillery: costs = [2: 160]
        case .magic: costs = [:]
        }
        return costs[level]
    }
}

/// A tower the player has built, keyed by its slot.
struct PlacedTower: Identifiable {
    let slotIndex: Int
    let kind: TowerKind
    let position: CGPoint
    /// Current tower level; 1 is the freshly built form.
    var level: Int = 1

    var id: Int { slotIndex }
}

/// Loads one level from the database and marches successive enemy waves along
/// its path, driven by the engine's `Timer` (Engine/Core/Timer.swift — the
/// same-module declaration shadows Foundation's Timer here). The Timer's tick
/// counter is the authoritative game time: each tick represents SimClock.dt of
/// game time, and the Timer's tickDuration is the real time each tick occupies
/// on screen.
///
/// Towers are built and upgraded by the player: tapping an empty slot opens
/// the radial build menu; tapping a placed tower opens the radial upgrade
/// menu. What may be built, and how far it may be upgraded, comes from the
/// level_tower_unlock table — per-level data, not code.
@MainActor
final class LevelRunner: NSObject, ObservableObject {
    /// One demo wave: a single enemy of the given type walking the full path.
    private struct WaveSpec {
        let enemyName: String
        let assetName: String
    }

    private static let waveSpecs = [
        WaveSpec(enemyName: "Loyalist Militia", assetName: "loyalist_militia"),
        WaveSpec(enemyName: "Regimental Drummer", assetName: "regimental_drummer"),
    ]

    /// Real time each simulation tick occupies at normal (×1) speed. One tick
    /// advances the game by SimClock.dt of game time, so pacing ticks at the
    /// same 1/30 s of real time runs the game 1:1 with the wall clock.
    private static let normalTickDuration: Duration = .seconds(1) / SimClock.ticksPerSecond

    /// The level map artwork's pixel size — the coordinate space path points
    /// (and tower slots) are authored in. Supplied per level by the campaign
    /// node that opened this runner.
    let mapImageSize: CGSize

    /// The level's playable rect from the database (see LevelMapProjection).
    private(set) var playableRect: CGRect

    /// Max buildable tower level per kind on THIS level, from the
    /// level_tower_unlock table. A kind with no entry is locked here.
    @Published private(set) var towerUnlocks: [TowerKind: Int] = [:]

    /// Kinds buildable on this level (derived from `towerUnlocks`).
    var availableTowerKinds: Set<TowerKind> { Set(towerUnlocks.keys) }

    /// Rendered height of the enemy sprite, in map-image pixels.
    let spriteHeightInImagePixels: CGFloat = 33.5

    /// Rendered height of a built tower's sprite, in map-image pixels.
    let towerHeightInImagePixels: CGFloat = 60

    /// Tower-slot platform centres, in map-image pixel space, in database order.
    private(set) var slotPositions: [CGPoint] = []

    /// Towers the player has built so far. Persist across the demo's wave loop.
    @Published private(set) var placedTowers: [PlacedTower] = []

    /// Empty slot whose radial BUILD menu is open, or nil.
    @Published private(set) var selectedSlotIndex: Int?

    /// Occupied slot whose radial UPGRADE menu is open, or nil.
    @Published private(set) var selectedTowerSlotIndex: Int?

    /// Current sprite position in map-image pixel space, or nil before the
    /// first tick / if the level failed to load.
    @Published private(set) var spritePosition: CGPoint?

    /// Asset-catalog image name for the enemy currently on the path.
    @Published private(set) var spriteAssetName: String = LevelRunner.waveSpecs[0].assetName

    /// Animation speed as a multiple of normal: doubles with each speed-up tap.
    @Published private(set) var speedMultiplier = 1

    /// A short human-readable status line for the HUD (what loaded, or why not).
    @Published private(set) var status: String = "Loading…"

    /// True once data loaded and there is a path to walk.
    private(set) var isReady = false

    private var path: Path?
    private var levelName = ""
    private var speedsByEnemyName: [String: Double] = [:]
    private var waveIndex = 0
    private var speed: Double = 0

    /// The engine's coordination clock, paced for on-screen play.
    private let timer = Timer(tickDuration: LevelRunner.normalTickDuration)
    /// Tick at which the current wave's enemy left the spawn.
    private var waveStartTick: Int64 = 0
    private var displayLink: CADisplayLink?

    init(levelInfoID: UUID?, mapImageSize: CGSize) {
        self.mapImageSize = mapImageSize
        self.playableRect = CGRect(origin: .zero, size: mapImageSize)
        super.init()
        load(levelInfoID: levelInfoID)
    }

    private func load(levelInfoID: UUID?) {
        guard let levelInfoID else {
            status = "This campaign node has no level_info id."
            return
        }
        // Fail soft instead of letting Db.init fatalError on a missing file.
        guard Bundle.main.url(forResource: "redcoat_raid", withExtension: "sqlite") != nil else {
            status = "redcoat_raid.sqlite is not in the app bundle."
            return
        }

        do {
            let db = Db(
                dbPath: Db.getAbsolutePathToDb(dbFilename: "redcoat_raid", fullRefresh: true),
                fullRefresh: true
            )
            let level = try db.levelInfoDao.getBy(id: levelInfoID)
            let enemies = try db.enemyTypeDao.getAll()

            // Per-level tower unlock caps, keyed in the DB by TowerKind rawValue.
            let unlockRows = try db.towerUnlockDao.getUnlocksFor(levelInfoId: levelInfoID)
            towerUnlocks = Dictionary(uniqueKeysWithValues: unlockRows.compactMap { key, value in
                TowerKind(rawValue: key).map { ($0, value) }
            })

            levelName = level.name
            playableRect = level.playableRect
            slotPositions = level.towerSlots.map { CGPoint(x: $0.position.x, y: $0.position.y) }

            guard let firstPath = level.paths.first else {
                status = "\(level.name): no path in the database."
                return
            }
            speedsByEnemyName = Dictionary(
                uniqueKeysWithValues: enemies.map { ($0.name, $0.stats.speed) }
            )
            for spec in Self.waveSpecs where speedsByEnemyName[spec.enemyName] == nil {
                status = "\(level.name): '\(spec.enemyName)' is not in the enemy_type roster."
                return
            }

            path = firstPath
            isReady = true
            enterWave(0)
        } catch {
            status = "Database load failed: \(error)"
        }
    }

    // MARK: - Build & upgrade menus

    func isSlotOccupied(_ index: Int) -> Bool {
        placedTowers.contains { $0.slotIndex == index }
    }

    func placedTower(atSlot index: Int) -> PlacedTower? {
        placedTowers.first { $0.slotIndex == index }
    }

    /// Max level the given kind may reach on this level (0 = locked here).
    func maxLevel(for kind: TowerKind) -> Int {
        towerUnlocks[kind] ?? 0
    }

    /// Tap on an empty slot: toggle its build menu.
    func selectSlot(_ index: Int) {
        guard !isSlotOccupied(index) else { return }
        selectedTowerSlotIndex = nil
        selectedSlotIndex = selectedSlotIndex == index ? nil : index
    }

    /// Tap on a placed tower: toggle its upgrade menu.
    func selectPlacedTower(atSlot index: Int) {
        guard isSlotOccupied(index) else { return }
        selectedSlotIndex = nil
        selectedTowerSlotIndex = selectedTowerSlotIndex == index ? nil : index
    }

    func dismissMenu() {
        selectedSlotIndex = nil
        selectedTowerSlotIndex = nil
    }

    /// Build the chosen tower kind in the slot whose build menu is open.
    func buildTower(_ kind: TowerKind) {
        guard let slotIndex = selectedSlotIndex,
              maxLevel(for: kind) >= 1,
              kind.assetName != nil,
              !isSlotOccupied(slotIndex),
              slotPositions.indices.contains(slotIndex)
        else { return }
        placedTowers.append(PlacedTower(
            slotIndex: slotIndex,
            kind: kind,
            position: slotPositions[slotIndex]
        ))
        selectedSlotIndex = nil
    }

    /// The upgrade offer for the tower whose upgrade menu is open:
    /// the level it would reach and the gold cost. Nil when the tower is at
    /// this level's cap (menu shows a maxed state instead).
    var upgradeOffer: (nextLevel: Int, cost: Int)? {
        guard let slotIndex = selectedTowerSlotIndex,
              let tower = placedTower(atSlot: slotIndex) else { return nil }
        let next = tower.level + 1
        guard next <= maxLevel(for: tower.kind),
              let cost = tower.kind.upgradeCost(to: next) else { return nil }
        return (next, cost)
    }

    /// Apply the open upgrade offer. (Cost is display-only until the level
    /// economy arrives — building and upgrading are free in the demo.)
    func upgradeSelectedTower() {
        guard let slotIndex = selectedTowerSlotIndex,
              let offer = upgradeOffer,
              let arrayIndex = placedTowers.firstIndex(where: { $0.slotIndex == slotIndex })
        else { return }
        placedTowers[arrayIndex].level = offer.nextLevel
        selectedTowerSlotIndex = nil
    }

    // MARK: - Waves

    /// Put the given wave's enemy at the path spawn. The timer is never reset —
    /// the wave's start tick is recorded instead.
    private func enterWave(_ index: Int) {
        waveIndex = index
        let spec = Self.waveSpecs[index]
        speed = speedsByEnemyName[spec.enemyName] ?? 0
        spriteAssetName = spec.assetName
        waveStartTick = timer.tick
        status = "\(levelName)  •  wave \(index + 1)/\(Self.waveSpecs.count): \(spec.enemyName)  •  \(Int(speed)) u/s"
    }

    /// Begin (or resume) walking. Safe to call repeatedly.
    func start() {
        guard isReady, displayLink == nil else { return }
        // Re-anchor the schedule so time spent stopped (backgrounded, on the
        // campaign map) doesn't replay as a catch-up sprint.
        timer.resync()
        enterWave(waveIndex)
        let link = CADisplayLink(target: self, selector: #selector(handleFrame))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    func stop() {
        displayLink?.invalidate()
        displayLink = nil
    }

    /// Halve the timer's tick duration: every simulation tick occupies half
    /// the real time, so the animation runs twice as fast (×2, ×4, ×8…).
    func speedUp() {
        timer.setTickDuration(timer.tickDuration / 2)
        speedMultiplier *= 2
    }

    @objc private func handleFrame() {
        step()
    }

    /// Drain due ticks, then place the sprite at the wave's distance along the
    /// path, interpolated for smooth motion at the display rate.
    private func step() {
        guard let path else { return }

        for _ in 0..<timer.dueTicks() {
            timer.advanceTick()
        }

        let ticksIntoWave = Double(timer.tick - waveStartTick) + timer.interpolationAlpha
        var distance = speed * ticksIntoWave * SimClock.dt
        if path.totalLength > 0, distance >= path.totalLength {
            // This walker reached the exit — the next wave starts at the spawn.
            enterWave((waveIndex + 1) % Self.waveSpecs.count)
            distance = 0
        }

        let p = path.point(atDistance: distance)
        spritePosition = CGPoint(x: p.x, y: p.y)
    }
}
