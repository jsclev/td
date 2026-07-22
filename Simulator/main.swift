// main.swift — revsim
// Headless batch runner. Opens (or creates) the content database, seeds it on
// first run, replays one level across N seeds with a scripted build order, and
// prints the balance report: win rate, lives percentiles, fate breakdown,
// rout share, and the per-wave tension trace.
import Foundation

struct Options {
    var dbPath = "revwar.sqlite"
    var inMemory = false
    var levelID = UUID(uuidString: "")
    var seeds = 200
    var baseSeed: UInt64 = 1776
    var reset = false
}

func printUsage() {
    print("""
    revsim — headless balance simulator

    USAGE: revsim [options]
      --db <path>      Content database path (default: revwar.sqlite)
      --memory         Use an in-memory database (seeds fresh every run)
      --level <id>     Level id to simulate (default: concord_road)
      --seeds <n>      Number of seeds to run (default: 200)
      --seed <n>       Base seed; runs use base, base+1, ... (default: 1776)
      --reset          Delete the database file first
      --help           Show this help
    """)
}

func parseOptions() throws -> Options? {
    var opts = Options()
    var args = ArraySlice(CommandLine.arguments.dropFirst())
    while let arg = args.popFirst() {
        switch arg {
        case "--db":
            guard let v = args.popFirst() else { return nil }
            opts.dbPath = v
        case "--memory":
            opts.inMemory = true
        case "--level":
            guard let v = args.popFirst() else { return nil }
            guard let uuid = UUID(uuidString: v) else {
                throw DbError.Db(message: "Unable to create UUID")
            }
            
            opts.levelID = uuid
        case "--seeds":
            guard let v = args.popFirst(), let n = Int(v), n > 0 else { return nil }
            opts.seeds = n
        case "--seed":
            guard let v = args.popFirst(), let n = UInt64(v) else { return nil }
            opts.baseSeed = n
        case "--reset":
            opts.reset = true
        case "--help", "-h":
            printUsage()
            exit(0)
        default:
            FileHandle.standardError.write(Data("Unknown option: \(arg)\n".utf8))
            return nil
        }
    }
    return opts
}

guard let opts = try parseOptions() else {
    printUsage()
    exit(2)
}

do {
    if opts.reset && !opts.inMemory {
        try? FileManager.default.removeItem(atPath: opts.dbPath)
    }

    let db = Db(dbPath: Db.getAbsolutePathToDb(dbFilename: "redcoat_raid", fullRefresh: false), fullRefresh: false)
    
    guard let levelInfoId = UUID(uuidString: "be3cf809-f71e-4209-bc4d-8b25b0b5f2a0") else {
        throw DbError.Db(message: "Unable to get level info id")
    }
    
    let levelInfo = try db.levelInfoDao.getBy(id: levelInfoId)

    // The tower_type / enemy_type tables exist but are not yet populated with
    // level/cost/range data, so the content catalog is assembled here for now.
    // Replace with a TowerTypeDAO once those tables carry the stat columns.
    let minutemanPost = TowerType(
        id: UUID(),
        name: "Minuteman Post",
        levels: [
            TowerLevel(cost: 70, range: 140, fireInterval: 0.9, shotMin: 4, shotMax: 7),
            TowerLevel(cost: 90, range: 150, fireInterval: 0.85, shotMin: 7, shotMax: 11),
        ]
    )
    let enemyTypes = try db.enemyTypeDao.getAll()
    let catalog = ContentCatalog(enemyTypes: enemyTypes, towerTypes: [minutemanPost])

    // Build the simulation for the loaded level. No waves or paths are in the
    // database yet, so the spawn schedule is empty and the run sits at the start
    // of wave 1 (wave index 0). We deliberately do not step() the simulation:
    // with an empty schedule the very first tick would satisfy the victory
    // condition. Waves become runnable once paths and wave data are seeded.
    let sim = try Simulation(
        level: levelInfo,
        catalog: catalog,
        policy: IdleCommander(),
        seed: opts.baseSeed
    )

    // Create a tower and assign it to the first slot.
    guard !levelInfo.towerSlots.isEmpty else {
        throw DbError.Db(message: "Level '\(levelInfo.name)' has no tower slots to place a tower in.")
    }
    let goldBefore = sim.gold
    let buildResult = sim.build(slot: 0, towerID: minutemanPost.id)
    guard buildResult == .ok else {
        throw DbError.Db(message: "Failed to place \(minutemanPost.name) in slot 0: \(buildResult)")
    }

    let occupiedSlots = sim.towers.filter { $0 != nil }.count

    print("""

    ── revsim ────────────────────────────────────────────
    level:        \(levelInfo.name) [\(levelInfo.id)]
    enemies:      \(enemyTypes.count) types loaded from roster
    tower slots:  \(levelInfo.towerSlots.count)
    tower built:  \(minutemanPost.name) → slot 0 (\(occupiedSlots)/\(levelInfo.towerSlots.count) occupied)
    gold:         \(goldBefore) → \(sim.gold)  (lives: \(sim.lives))
    initialized:  wave 1  (waves loaded: \(levelInfo.waves.count), paths loaded: \(levelInfo.paths.count))
    ──────────────────────────────────────────────────────

    """)

    // Walk one enemy along the level's path, driven by the game clock. Movement
    // is the engine's own model — distance += speed * dt each tick — with the
    // clock supplying the fixed dt independent of wall-clock time, so this is
    // deterministic and runs as fast as the CPU allows. This mirrors what
    // Simulation.step() does per enemy; here it is isolated to demonstrate the
    // timer moving a unit along the real path at its type's speed.
    guard let path = levelInfo.paths.first else {
        throw DbError.Db(message: "Level '\(levelInfo.name)' has no path to walk. Seed level_path_point first.")
    }
    let walker = enemyTypes.first(where: { $0.name == "Redcoat Regular" }) ?? enemyTypes[0]
    let speed = walker.stats.speed
    let clock = GameClock()

    func fmt(_ v: Double, _ d: Int = 1) -> String { String(format: "%.\(d)f", v) }
    func sample(distance: Double) {
        let p = path.point(atDistance: distance)
        let pct = path.totalLength > 0 ? distance / path.totalLength * 100 : 0
        print("  t=\(fmt(clock.time))s  tick \(String(format: "%4d", clock.tick))  "
            + "dist \(String(format: "%7.1f", distance)) (\(String(format: "%3.0f", pct))%)  "
            + "pos (\(fmt(p.x)), \(fmt(p.y)))")
    }

    print("""
    ── enemy walk (GameClock) ────────────────────────────
    enemy:   \(walker.name)  (speed \(fmt(speed, 0)) units/s)
    path:    \(path.points.count) points, length \(fmt(path.totalLength)) units
    clock:   \(clock.ticksPerSecond) ticks/s  (dt \(fmt(clock.dt, 4))s)

    """)

    var distance = 0.0
    sample(distance: distance)                      // t = 0, at the spawn
    var nextSampleTick = clock.ticksPerSecond       // then once per game-second
    while distance < path.totalLength {
        clock.advance()
        distance = min(path.totalLength, distance + speed * clock.dt)
        if clock.tick >= nextSampleTick {
            sample(distance: distance)
            nextSampleTick += clock.ticksPerSecond
        }
    }
    if clock.tick % clock.ticksPerSecond != 0 { sample(distance: distance) }  // final position

    print("""

    arrived at exit in \(fmt(clock.time))s (\(clock.tick) ticks)
    ──────────────────────────────────────────────────────

    """)
} catch {
    FileHandle.standardError.write(Data("revsim error: \(error)\n".utf8))
    exit(1)
}
