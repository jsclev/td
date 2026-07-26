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
    /// art (the unavailable kinds don't need any yet).
    var assetName: String? {
        switch self {
        case .ranged: return "minuteman_post"
        case .melee: return "militia_barracks"
        case .artillery, .magic: return nil
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
}

/// A tower the player has built, keyed by its slot.
struct PlacedTower: Identifiable {
    let slotIndex: Int
    let kind: TowerKind
    let position: CGPoint

    var id: Int { slotIndex }
}

/// Loads one level from the database and marches successive enemy waves along
/// its path, driven by the engine's `Timer` (Engine/Core/Timer.swift — the
/// same-module declaration shadows Foundation's Timer here). The Timer's tick
/// counter is the authoritative game time: each tick represents SimClock.dt of
/// game time, and the Timer's tickDuration is the real time each tick occupies
/// on screen. Halving the tickDuration doubles the animation speed without
/// changing what the simulation computes — same ticks, tighter spacing.
///
/// Towers are built by the player: tapping an empty slot opens the radial
/// build menu (see LevelMapView), and choosing an available kind places it.
@MainActor
final class LevelRunner: NSObject, ObservableObject {
    /// One demo wave: a single enemy of the given type walking the full path.
    /// Speeds come from the enemy_type roster in the database; only the sprite
    /// asset pairing lives here.
    private struct WaveSpec {
        let enemyName: String
        let assetName: String
    }

    /// The demo wave sequence. When a walker reaches the exit, the next wave's
    /// enemy spawns at the path start; after the last wave it loops back to
    /// wave 1 so the demo runs continuously.
    private static let waveSpecs = [
        WaveSpec(enemyName: "Loyalist Militia", assetName: "loyalist_militia"),
        WaveSpec(enemyName: "Regimental Drummer", assetName: "regimental_drummer"),
    ]

    /// Real time each simulation tick occupies at normal (×1) speed. One tick
    /// advances the game by SimClock.dt of game time, so pacing ticks at the
    /// same 1/30 s of real time runs the game 1:1 with the wall clock — the
    /// walking pace already tuned on device. The speed-up control halves this.
    private static let normalTickDuration: Duration = .seconds(1) / SimClock.ticksPerSecond

    /// Tower kinds buildable on level 1: ranged and melee. Artillery and magic
    /// appear in the menu but locked. Later this becomes per-level unlock data.
    let availableTowerKinds: Set<TowerKind> = [.ranged, .melee]

    /// The level map artwork's pixel size — the coordinate space path points
    /// (and tower slots) are authored in. Supplied per level by the campaign
    /// node that opened this runner.
    let mapImageSize: CGSize

    /// The level's playable rect from the database: the exactly-16:9 region of
    /// the art that must always be fully on screen (no map panning, ever). The
    /// view scales and centres the map so this rect fits the screen exactly.
    /// Falls back to the full art bounds until the level loads.
    private(set) var playableRect: CGRect

    /// Rendered height of the enemy sprite, in map-image pixels (scaled to the
    /// view alongside the map). This is the single knob for sprite size on the
    /// map: the source art stays full-resolution and is scaled down to this.
    /// Sized so the soldier sits comfortably on the road (~40px wide); a tower
    /// platform is ~90px across for reference. Nudge to taste.
    let spriteHeightInImagePixels: CGFloat = 33.5

    /// Rendered height of a built tower's sprite, in map-image pixels. Sized to
    /// sit on a tower-slot platform (~90px across); nudge to taste.
    let towerHeightInImagePixels: CGFloat = 60

    /// Tower-slot platform centres, in map-image pixel space, in database order.
    private(set) var slotPositions: [CGPoint] = []

    /// Towers the player has built so far. Persist across the demo's wave loop.
    @Published private(set) var placedTowers: [PlacedTower] = []

    /// Slot whose radial build menu is open, or nil when no menu is showing.
    @Published private(set) var selectedSlotIndex: Int?

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
            levelName = level.name
            playableRect = level.playableRect
            slotPositions = level.towerSlots.map { CGPoint(x: $0.position.x, y: $0.position.y) }

            isReady = true
            enterWave(0)
        } catch {
            status = "Database load failed: \(error)"
        }
    }

    // MARK: - Build menu

    func isSlotOccupied(_ index: Int) -> Bool {
        placedTowers.contains { $0.slotIndex == index }
    }

    /// Tap on a slot: open its build menu (or close it if already open).
    /// Occupied slots have no menu — upgrades come later.
    func selectSlot(_ index: Int) {
        guard !isSlotOccupied(index) else { return }
        selectedSlotIndex = selectedSlotIndex == index ? nil : index
    }

    func dismissMenu() {
        selectedSlotIndex = nil
    }

    /// Build the chosen tower kind in the slot whose menu is open.
    func buildTower(_ kind: TowerKind) {
        guard let slotIndex = selectedSlotIndex,
              availableTowerKinds.contains(kind),
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

    // MARK: - Waves

    /// Put the given wave's enemy at the path spawn. The timer is never reset —
    /// the wave's start tick is recorded instead, keeping one monotonic
    /// timeline for the whole level.
    private func enterWave(_ index: Int) {
        waveIndex = index
        let spec = Self.waveSpecs[index]
        speed = speedsByEnemyName[spec.enemyName] ?? 0
        spriteAssetName = spec.assetName
        waveStartTick = timer.tick
        status = "\(levelName)  •  wave \(index + 1)/\(Self.waveSpecs.count): \(spec.enemyName)  •  \(Int(speed)) u/s"
    }

    /// Begin (or resume) walking. Safe to call repeatedly. A `CADisplayLink`
    /// fires per display frame (120Hz on ProMotion); each frame drains the
    /// ticks the Timer says are due and renders an interpolated position.
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
    /// the real time, so the animation runs twice as fast. Repeated taps keep
    /// doubling (×2, ×4, ×8…). Game outcomes are unaffected by construction —
    /// same ticks, different spacing.
    func speedUp() {
        timer.setTickDuration(timer.tickDuration / 2)
        speedMultiplier *= 2
    }

    @objc private func handleFrame() {
        step()
    }

    /// Drain due ticks (game logic would run here, once per tick), then place
    /// the sprite at the wave's distance along the path. Rendering uses the
    /// Timer's interpolation alpha — the fraction of the way to the next tick —
    /// so motion stays smooth at the display rate regardless of tick pacing.
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
