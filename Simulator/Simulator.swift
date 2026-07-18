//// main.swift — revsim
//// Headless batch runner. Opens (or creates) the content database, seeds it on
//// first run, replays one level across N seeds with a scripted build order, and
//// prints the balance report: win rate, lives percentiles, fate breakdown,
//// rout share, and the per-wave tension trace.
//
//import Foundation
//
//// MARK: - Arguments
//
//struct Options {
//    var dbPath = "revwar.sqlite"
//    var inMemory = false
//    var levelID = "concord_road"
//    var seeds = 200
//    var baseSeed: UInt64 = 1776
//    var reset = false
//}
//
//func printUsage() {
//    print("""
//    revsim — headless balance simulator
//
//    USAGE: revsim [options]
//      --db <path>      Content database path (default: revwar.sqlite)
//      --memory         Use an in-memory database (seeds fresh every run)
//      --level <id>     Level id to simulate (default: concord_road)
//      --seeds <n>      Number of seeds to run (default: 200)
//      --seed <n>       Base seed; runs use base, base+1, ... (default: 1776)
//      --reset          Delete the database file first
//      --help           Show this help
//    """)
//}
//
//func parseOptions() -> Options? {
//    var opts = Options()
//    var args = ArraySlice(CommandLine.arguments.dropFirst())
//    while let arg = args.popFirst() {
//        switch arg {
//        case "--db":
//            guard let v = args.popFirst() else { return nil }
//            opts.dbPath = v
//        case "--memory":
//            opts.inMemory = true
//        case "--level":
//            guard let v = args.popFirst() else { return nil }
//            opts.levelID = v
//        case "--seeds":
//            guard let v = args.popFirst(), let n = Int(v), n > 0 else { return nil }
//            opts.seeds = n
//        case "--seed":
//            guard let v = args.popFirst(), let n = UInt64(v) else { return nil }
//            opts.baseSeed = n
//        case "--reset":
//            opts.reset = true
//        case "--help", "-h":
//            printUsage()
//            exit(0)
//        default:
//            FileHandle.standardError.write(Data("Unknown option: \(arg)\n".utf8))
//            return nil
//        }
//    }
//    return opts
//}
//
//// MARK: - Demo build order (the "intended solution" for concord_road)
//
//func demoBuildOrder() -> ScriptedBuildOrder {
//    ScriptedBuildOrder(steps: [
//        .init(time: 0, action: .build(slot: 2, towerID: "minuteman_post")),
//        .init(time: 0, action: .build(slot: 1, towerID: "volley_line")),
//        .init(time: 25, action: .build(slot: 4, towerID: "long_rifles")),
//        .init(time: 60, action: .build(slot: 3, towerID: "field_cannon")),
//        .init(time: 95, action: .upgrade(slot: 1)),
//        .init(time: 115, action: .upgrade(slot: 2)),
//        .init(time: 150, action: .upgrade(slot: 3)),
//        .init(time: 170, action: .upgrade(slot: 4)),
//    ])
//}
//
//// MARK: - Main
//
//guard let opts = parseOptions() else {
//    printUsage()
//    exit(2)
//}
//
//do {
//    if opts.reset && !opts.inMemory {
//        try? FileManager.default.removeItem(atPath: opts.dbPath)
//    }
//
//    let path = opts.inMemory ? ":memory:" : opts.dbPath
//    let db = try SQLiteDatabase(path: path)
//    try Migrations.migrate(db)
//
//    let repo = ContentRepository(db: db)
//    if try SeedContent.seedIfNeeded(into: repo) {
//        print("Seeded content database (\(path)) with Crown Forces roster + demo level.")
//    }
//
//    let catalog = try repo.loadCatalog()
//    let level = try repo.loadLevel(id: opts.levelID)
//
//    print("""
//
//    ── revsim ────────────────────────────────────────────
//    level:   \(level.name) [\(level.id)]
//    content: \(catalog.enemyTypes.count) enemy types, \(catalog.towerTypes.count) tower types
//    runs:    \(opts.seeds) seeds starting at \(opts.baseSeed)
//    """)
//
//    let started = Date()
//    let report = try Batch.run(
//        level: level,
//        catalog: catalog,
//        baseSeed: opts.baseSeed,
//        count: opts.seeds,
//        makePolicy: { _ in demoBuildOrder() }
//    )
//    let elapsed = Date().timeIntervalSince(started)
//
//    let pct = { (v: Double) in String(format: "%.1f%%", v * 100) }
//    print("""
//    outcome: \(report.victories) victories / \(report.defeats) defeats / \(report.timeouts) timeouts  (win rate \(pct(report.winRate)))
//    lives remaining  p5: \(String(format: "%.0f", report.livesPercentile(5)))   p50: \(String(format: "%.0f", report.livesPercentile(50)))   p95: \(String(format: "%.0f", report.livesPercentile(95)))
//    fates:   killed \(report.totalKilled) · routed \(report.totalRouted) · captured \(report.totalCaptured) · leaked \(report.totalLeaked)
//    rout share of removals: \(pct(report.routShare))
//    """)
//
//    print("wave pressure (mean max progress toward exit):")
//    for (i, v) in report.meanWaveMaxProgress.enumerated() {
//        let filled = max(0, min(30, Int((v * 30).rounded())))
//        let bar = String(repeating: "█", count: filled)
//            + String(repeating: "·", count: 30 - filled)
//        let prefix = String(format: "  wave %2d  ", i + 1)
//        let suffix = String(format: " %5.1f%%", v * 100)
//        print(prefix + bar + suffix)
//    }
//
//    let rate = elapsed > 0 ? Double(opts.seeds) / elapsed : 0
//    print(String(format: "\n%d sims in %.2fs (%.1f sims/sec)", opts.seeds, elapsed, rate))
//    print("──────────────────────────────────────────────────────\n")
//} catch {
//    FileHandle.standardError.write(Data("revsim error: \(error)\n".utf8))
//    exit(1)
//}
