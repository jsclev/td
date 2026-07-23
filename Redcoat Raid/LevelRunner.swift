import Foundation
import CoreGraphics
import Combine
import QuartzCore

/// Loads one level from the database and walks an enemy along its path, driven
/// by the engine's `GameClock`. This is the level-view counterpart to the
/// headless simulator run: same data source, same fixed-timestep clock, same
/// `distance = speed * time` movement model — here paced to real time and
/// interpolated so the sprite animates smoothly on screen.
@MainActor
final class LevelRunner: NSObject, ObservableObject {
    /// The level map artwork's pixel size — the coordinate space path points
    /// (and tower slots) are authored in. Keep in sync if the art is replaced.
    let mapImageSize = CGSize(width: 1447, height: 1087)

    /// Rendered height of the enemy sprite, in map-image pixels (scaled to the
    /// view alongside the map). This is the single knob for sprite size on the
    /// map: the source art stays full-resolution and is scaled down to this.
    /// Sized so the soldier sits comfortably on the road (~40px wide); a tower
    /// platform is ~90px across for reference. Nudge to taste.
    let spriteHeightInImagePixels: CGFloat = 33.5

    /// Current sprite position in map-image pixel space, or nil before the
    /// first tick / if the level failed to load.
    @Published private(set) var spritePosition: CGPoint?

    /// A short human-readable status line for the HUD (what loaded, or why not).
    @Published private(set) var status: String = "Loading…"

    /// True once data loaded and there is a path to walk.
    private(set) var isReady = false

    private var path: Path?
    private var speed: Double = 0

    private let clock = GameClock()
    private var startDate = Date()
    private var displayLink: CADisplayLink?

    init(levelInfoID: UUID?) {
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

            guard let firstPath = level.paths.first else {
                status = "\(level.name): no path in the database."
                return
            }
            guard let militia = enemies.first(where: { $0.name == "Loyalist Militia" }) ?? enemies.first else {
                status = "\(level.name): no enemy types loaded."
                return
            }

            path = firstPath
            speed = militia.stats.speed
            isReady = true
            status = "\(level.name)  •  \(militia.name)  •  \(Int(militia.stats.speed)) u/s  •  \(firstPath.points.count) path points"
        } catch {
            status = "Database load failed: \(error)"
        }
    }

    /// Begin (or resume) walking. Safe to call repeatedly. A `CADisplayLink`
    /// ticks this in step with the display refresh (120Hz on ProMotion), so the
    /// sprite is repositioned every frame rather than every simulation tick.
    func start() {
        guard isReady, displayLink == nil else { return }
        clock.reset()
        startDate = Date()
        let link = CADisplayLink(target: self, selector: #selector(handleFrame))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    func stop() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func handleFrame() {
        step()
    }

    /// Advance the fixed-timestep clock up to now (where game logic would run at
    /// 30Hz), then place the sprite at an *interpolated* distance: how far into
    /// the current tick we are, blended across the tick. That decouples the
    /// on-screen motion from the 30Hz step, so it's smooth at the display's full
    /// refresh rate. For constant speed this is exact; when speed varies (from
    /// the simulation), it's the standard fixed-timestep render interpolation.
    private func step() {
        guard let path else { return }

        let elapsed = Date().timeIntervalSince(startDate)
        while clock.time + clock.dt <= elapsed {
            clock.advance()
        }

        let alpha = min(1.0, max(0.0, (elapsed - clock.time) / clock.dt))
        let renderTime = clock.time + alpha * clock.dt

        var distance = speed * renderTime
        if path.totalLength > 0, distance >= path.totalLength {
            // Reached the exit — loop the march so the demo runs continuously.
            clock.reset()
            startDate = Date()
            distance = 0
        }

        let p = path.point(atDistance: distance)
        spritePosition = CGPoint(x: p.x, y: p.y)
    }
}
