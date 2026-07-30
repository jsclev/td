import SwiftUI

/// Maps points from the level art's pixel space onto the screen, anchored to
/// the level's playable rect: the map is scaled uniformly so the playable rect
/// exactly fits the screen (never clipped in either axis) and its centre sits
/// at the screen's centre. Art outside the playable rect is bleed.
struct LevelMapProjection {
    let imageSize: CGSize
    let playableRect: CGRect
    let viewSize: CGSize

    var scale: CGFloat {
        min(viewSize.width / playableRect.width, viewSize.height / playableRect.height)
    }

    private var origin: CGPoint {
        CGPoint(
            x: viewSize.width / 2 - playableRect.midX * scale,
            y: viewSize.height / 2 - playableRect.midY * scale
        )
    }

    func viewPoint(_ p: CGPoint) -> CGPoint {
        CGPoint(x: origin.x + p.x * scale, y: origin.y + p.y * scale)
    }

    func viewLength(_ l: CGFloat) -> CGFloat { l * scale }

    var imageFrameSize: CGSize {
        CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
    }

    var imageCenter: CGPoint {
        viewPoint(CGPoint(x: imageSize.width / 2, y: imageSize.height / 2))
    }
}

/// Fixed geometry shared by both radial menus (build and upgrade). A hard
/// game-design rule: these never rotate, resize, or adapt per slot or level —
/// maps must be designed so the menus always fit on screen.
///
/// The menu background is painted art: tower_menu_v02 (1536px canvas) for the
/// 4-choice build ring (bubbles on the diagonals), radial_menu_1_choice …
/// radial_menu_3_choices (1536px canvases) for the other counts. Each
/// painting's bubbles are hand-placed, so item positions, parchment size, and
/// scale are per-count measurements from the art; the scale maps art pixels
/// to points so the tappable items land exactly on the painted bubbles, with
/// every variant's bubble centers at the same on-screen spread.
enum RadialMenu {
    /// Distance from the slot to every bubble's center (also the fallback
    /// even-spacing radius for counts with no painted variant).
    static let radius: CGFloat = 114.4825

    /// Tap target for one choice, independent of the painted bubble's size.
    static let itemDiameter: CGFloat = 70

    /// tower_menu_v02's bubbles sit 518px out on its 1536px canvas; this
    /// scale (90.5/409.5, carried over from tower_menu_v01) keeps the painted
    /// bubbles at their previous on-screen size, which lands their centers at
    /// `radius` (518 × 90.5/409.5 ≈ 114.5).
    private static let fourChoiceArtScale: CGFloat = 90.5 / 409.5

    /// The ring variants' bubbles sit 541px out on their 1536px canvases;
    /// this seats items exactly on them at the same `radius` spread as the
    /// build ring.
    private static let variantArtScale: CGFloat = radius / 541

    /// Downward nudge of a tower icon within its parchment well, as a
    /// fraction of the well's diameter — the icons sit low in the bubble.
    static let iconDropFraction: CGFloat = 0.045

    /// Per-kind seat within the well: the musketman and militiaman art sit
    /// visually low, so they ride 2% higher than the others.
    static func iconDropFraction(for kind: TowerKind) -> CGFloat {
        switch kind {
        case .ranged, .melee: iconDropFraction - 0.04
        case .artillery, .magic: iconDropFraction
        }
    }

    /// One painted menu image: its bubble centers relative to the canvas
    /// center in art pixels (in the order menu items occupy them), its
    /// parchment disc diameter, and the fixed scale that preserves the
    /// bubbles' previous on-screen size.
    private struct Art {
        let assetName: String
        let canvasPx: CGFloat
        let parchmentPx: CGFloat
        let pointsPerPx: CGFloat
        let bubbleOffsetsPx: [CGSize]
    }

    private static let arts: [Int: Art] = [
        1: Art(assetName: "radial_menu_1_choice", canvasPx: 1536,
               parchmentPx: 192, pointsPerPx: variantArtScale,
               bubbleOffsetsPx: [CGSize(width: 0, height: -540)]),
        2: Art(assetName: "radial_menu_2_choices", canvasPx: 1536,
               parchmentPx: 192, pointsPerPx: variantArtScale,
               bubbleOffsetsPx: [CGSize(width: 0, height: -540),
                                 CGSize(width: 0, height: 543)]),
        3: Art(assetName: "radial_menu_3_choices", canvasPx: 1536,
               parchmentPx: 192, pointsPerPx: variantArtScale,
               bubbleOffsetsPx: [CGSize(width: 0, height: -540),
                                 CGSize(width: 469, height: 270),
                                 CGSize(width: -469, height: 271)]),
        // Upper-left, upper-right, lower-right, lower-left: TowerKind.allCases
        // order puts ranged UL, melee UR, artillery LR, magic LL.
        4: Art(assetName: "tower_menu_v02", canvasPx: 1536,
               parchmentPx: 251, pointsPerPx: fourChoiceArtScale,
               bubbleOffsetsPx: [CGSize(width: -366, height: -366),
                                 CGSize(width: 366, height: -366),
                                 CGSize(width: 366, height: 366),
                                 CGSize(width: -366, height: 366)]),
    ]

    private static func art(count: Int) -> Art {
        arts[min(max(count, 1), 4)]!
    }

    static func backgroundAssetName(count: Int) -> String {
        art(count: count).assetName
    }

    /// On-screen edge length of the square background image.
    static func backgroundDiameter(count: Int) -> CGFloat {
        let art = art(count: count)
        return art.canvasPx * art.pointsPerPx
    }

    /// On-screen diameter of a bubble's parchment disc — the icon's well.
    static func iconWellDiameter(count: Int) -> CGFloat {
        let art = art(count: count)
        return art.parchmentPx * art.pointsPerPx
    }

    /// The item's center offset from the slot, in points: the painted bubble's
    /// position when the art has a variant for `count`, even spacing otherwise.
    static func itemOffset(index: Int, count: Int) -> CGSize {
        let art = art(count: count)
        guard art.bubbleOffsetsPx.indices.contains(index) else {
            let angle = Angle.degrees(-90 + Double(index) * 360 / Double(count))
            return CGSize(width: radius * cos(angle.radians),
                          height: radius * sin(angle.radians))
        }
        return CGSize(width: art.bubbleOffsetsPx[index].width * art.pointsPerPx,
                      height: art.bubbleOffsetsPx[index].height * art.pointsPerPx)
    }
}

/// A single battle's level map: the painted map aspect-anchored to the screen,
/// enemies walking the level's path, and Kingdom Rush-style tower building —
/// tap an empty slot for the radial build menu; tap a placed tower for the
/// radial upgrade menu (upgrade shown with its gold cost at the ring's top).
struct LevelMapView: View {
    var node: CampaignNode
    var onExit: () -> Void

    @StateObject private var runner: LevelRunner

    /// Shows the debug info panel (the runner's status line). Off by default;
    /// flip the stored "showDebugInfo" default (or set it from any future
    /// settings/debug UI) to turn it on at runtime — no rebuild needed.
    @AppStorage("showDebugInfo") private var showDebugInfo = false

    init(node: CampaignNode, onExit: @escaping () -> Void) {
        self.node = node
        self.onExit = onExit
        _runner = StateObject(wrappedValue: LevelRunner(
            levelInfoID: node.levelInfoID,
            mapImageSize: node.mapImageSize
        ))
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            GeometryReader { geometry in
                content(in: geometry.size)
            }
            .ignoresSafeArea()

            // The HUD sits outside the safe-area-ignoring game layer, so it
            // is always fully on screen regardless of notch or rounded
            // corners; its padding is the comfortable buffer beyond that.
            hud

            // Corner control cluster: pause (exit to campaign map) in the
            // corner, speed-up to its left.
            HStack(spacing: 14) {
                speedButton
                pauseButton
            }
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        }
        .persistentSystemOverlays(.hidden)
        .onAppear { runner.start() }
        .onDisappear { runner.stop() }
    }

    /// Tapping doubles the game speed. Speed state will read from the button
    /// art itself eventually; no multiplier label until then.
    private var speedButton: some View {
        Button {
            runner.speedUp()
        } label: {
            Image("speed_up_icon")
                .resizable()
                .scaledToFit()
                .frame(width: 92.4, height: 92.4)
        }
        .buttonStyle(.plain)
    }

    /// Sends the player back to the main campaign map (a proper pause menu
    /// may hang off this later).
    private var pauseButton: some View {
        Button(action: onExit) {
            Image("pause_icon")
                .resizable()
                .scaledToFit()
                .frame(width: 92.4, height: 92.4)
        }
        .buttonStyle(.plain)
    }

    private func content(in viewSize: CGSize) -> some View {
        let projection = LevelMapProjection(
            imageSize: runner.mapImageSize,
            playableRect: runner.playableRect,
            viewSize: viewSize
        )

        return ZStack(alignment: .topLeading) {
            Color.black

            Image(node.mapImageName)
                .resizable()
                .frame(width: projection.imageFrameSize.width,
                       height: projection.imageFrameSize.height)
                .position(projection.imageCenter)

            // Built towers (with a level numeral once upgraded).
            ForEach(runner.placedTowers) { tower in
                if let assetName = tower.kind.assetName {
                    let towerHeight = projection.viewLength(tower.kind.spriteHeightInImagePixels)
                    let basePoint = projection.viewPoint(tower.position)
                    ZStack(alignment: .bottom) {
                        Image(assetName)
                            .resizable()
                            .scaledToFit()
                            .frame(height: towerHeight)
                        if tower.level > 1 {
                            Text(["", "I", "II", "III", "IV", "V"][tower.level])
                                .font(.system(size: 13, weight: .heavy, design: .serif))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 2)
                                .background(Color(red: 0.62, green: 0.12, blue: 0.12), in: Capsule())
                                .overlay(Capsule().strokeBorder(Color(red: 0.85, green: 0.7, blue: 0.3), lineWidth: 2))
                                .offset(y: 10)
                        }
                    }
                    // Anchor the tower's base just past the platform centre.
                    .position(
                        x: basePoint.x,
                        y: basePoint.y - towerHeight / 2 + projection.viewLength(14)
                            + towerHeight * 0.10
                    )
                }
            }

            // The enemy on the path.
            if let position = runner.spritePosition {
                let spriteHeight = projection.viewLength(runner.spriteHeightInImagePixels)
                let footPoint = projection.viewPoint(position)
                Image(runner.spriteAssetName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: spriteHeight)
                    .position(x: footPoint.x, y: footPoint.y - spriteHeight / 2)
            }

            // Tap targets over every slot: empty ones open the build menu,
            // occupied ones open the upgrade menu.
            ForEach(Array(runner.slotPositions.enumerated()), id: \.offset) { index, slotPosition in
                Button {
                    if runner.isSlotOccupied(index) {
                        runner.selectPlacedTower(atSlot: index)
                    } else {
                        runner.selectSlot(index)
                    }
                } label: {
                    Circle()
                        .fill(Color.white.opacity(0.001))
                        .frame(width: 64, height: 64)
                }
                .position(projection.viewPoint(slotPosition))
            }

            // Radial menus around the selected slot.
            if let buildSlot = runner.selectedSlotIndex,
               runner.slotPositions.indices.contains(buildSlot) {
                dismissCatcher(viewSize: viewSize)
                radialBuildMenu(around: projection.viewPoint(runner.slotPositions[buildSlot]))
            }
            if let upgradeSlot = runner.selectedTowerSlotIndex,
               runner.slotPositions.indices.contains(upgradeSlot),
               let tower = runner.placedTower(atSlot: upgradeSlot) {
                dismissCatcher(viewSize: viewSize)
                upgradeMenu(for: tower, around: projection.viewPoint(runner.slotPositions[upgradeSlot]))
            }

        }
    }

    /// Full-screen transparent layer: tapping anywhere else closes the menu.
    private func dismissCatcher(viewSize: CGSize) -> some View {
        Color.black.opacity(0.001)
            .frame(width: viewSize.width, height: viewSize.height)
            .onTapGesture { runner.dismissMenu() }
    }

    /// The build ring: the painted ring art centered on the slot, with one
    /// tower-kind item on each painted bubble.
    private func radialBuildMenu(around center: CGPoint) -> some View {
        let kinds = TowerKind.allCases
        return Group {
            radialMenuBackground(count: kinds.count, center: center)
            ForEach(Array(kinds.enumerated()), id: \.element) { index, kind in
                let offset = RadialMenu.itemOffset(index: index, count: kinds.count)
                BuildMenuItem(kind: kind, isAvailable: runner.maxLevel(for: kind) >= 1) {
                    runner.buildTower(kind)
                }
                .position(x: center.x + offset.width, y: center.y + offset.height)
            }
        }
    }

    /// The upgrade ring: the single-bubble ring art with one item on the top
    /// bubble — the next tower level and its gold cost, or a maxed-out state
    /// when this level's unlock cap (level_tower_unlock) has been reached.
    private func upgradeMenu(for tower: PlacedTower, around center: CGPoint) -> some View {
        let offset = RadialMenu.itemOffset(index: 0, count: 1)
        return Group {
            radialMenuBackground(count: 1, center: center)
            UpgradeMenuItem(tower: tower, offer: runner.upgradeOffer) {
                runner.upgradeSelectedTower()
            }
            .position(x: center.x + offset.width, y: center.y + offset.height)
        }
    }

    /// The painted ring-and-bubbles image behind a radial menu's items. Not
    /// hit-testable so taps on its empty regions still reach the dismiss
    /// catcher underneath.
    private func radialMenuBackground(count: Int, center: CGPoint) -> some View {
        Image(RadialMenu.backgroundAssetName(count: count))
            .resizable()
            .frame(width: RadialMenu.backgroundDiameter(count: count),
                   height: RadialMenu.backgroundDiameter(count: count))
            .position(center)
            .allowsHitTesting(false)
    }

    /// The player stats — lives, gold, and wave — pinned to the upper-left,
    /// with the dev scaffolding rows (exit, status, speed) below them.
    private var hud: some View {
        VStack(alignment: .leading, spacing: 12) {
            statsPanel

            if showDebugInfo {
                Text(runner.status)
                    .font(.footnote.monospaced())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.black.opacity(0.55), in: RoundedRectangle(cornerRadius: 8))
            }

            Spacer()
        }
        .padding(16)
    }

    /// Hardcoded placeholder values until the lives, gold, and wave systems
    /// exist. Lives and gold share the top row (the usual tower-defense
    /// arrangement); the wave line gets an icon once its art arrives.
    private var statsPanel: some View {
        HStack(spacing: 33) {
            statRow(icon: "lives_icon", value: "20", iconSize: 57.7)
            statRow(icon: "gold_icon", value: "250", iconSize: 57.7)
            statRow(icon: "wave_number_icon", value: "Wave 1 of 8", iconSize: 63.5)
        }
    }

    /// One stat: the icon with its value in the system's thickest cut
    /// (black-weight rounded), which stays legible over busy map art.
    private func statRow(icon: String, value: String, iconSize: CGFloat = 48.5) -> some View {
        HStack(spacing: 8) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
            Text(value)
                .font(.system(size: 37.1, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.85), radius: 2, x: 0, y: 1)
        }
    }
}

/// One choice in the radial build menu, drawn over a painted parchment bubble
/// in the ring art: the tower kind's icon when unlocked on this level, the
/// padlock otherwise. No label — the icon carries the meaning.
private struct BuildMenuItem: View {
    let kind: TowerKind
    let isAvailable: Bool
    let action: () -> Void

    /// The parchment well this item sits on: the build ring always shows every
    /// tower kind, so its art is the `TowerKind.allCases.count` variant.
    private var well: CGFloat {
        RadialMenu.iconWellDiameter(count: TowerKind.allCases.count)
    }

    var body: some View {
        // A regular button for every kind — never disabled, since SwiftUI
        // dims a disabled button's contents, visibly shifting the art's
        // colors. Tapping a locked kind is a no-op (buildTower guards it).
        Button(action: action) { icon }
            .buttonStyle(.plain)
    }

    /// The icon art carries its own margins, so it fills the painted
    /// parchment disc exactly; the padlock art runs a touch large for the
    /// well, so it renders smaller.
    private var icon: some View {
        Image(isAvailable ? kind.menuIconName : "tower_locked_icon")
            .resizable()
            .scaledToFit()
            .frame(width: isAvailable ? well : well * 0.81,
                   height: isAvailable ? well : well * 0.81)
            .offset(y: well * (isAvailable
                ? RadialMenu.iconDropFraction(for: kind)
                : RadialMenu.iconDropFraction))
            .frame(width: RadialMenu.itemDiameter, height: RadialMenu.itemDiameter)
            .contentShape(Rectangle())
    }
}

/// The single item of the upgrade menu, drawn over the painted bubble: the
/// tower's sprite with the level it would upgrade to, and the gold cost below
/// — or a grey MAX state when the tower has reached this level's unlock cap.
private struct UpgradeMenuItem: View {
    let tower: PlacedTower
    let offer: (nextLevel: Int, cost: Int)?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                ZStack {
                    let well = RadialMenu.iconWellDiameter(count: 1)
                    Image(tower.kind.menuIconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: well, height: well)
                        .offset(y: well * RadialMenu.iconDropFraction(for: tower.kind))
                        .opacity(offer != nil ? 1 : 0.5)
                    if let offer {
                        Text(["", "I", "II", "III", "IV", "V"][offer.nextLevel])
                            .font(.system(size: 15, weight: .heavy, design: .serif))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 1)
                            .background(Color(red: 0.62, green: 0.12, blue: 0.12), in: Capsule())
                            .offset(y: 18)
                    }
                }
                .frame(width: RadialMenu.itemDiameter, height: RadialMenu.itemDiameter)

                if let offer {
                    Label("\(offer.cost)", systemImage: "circle.fill")
                        .font(.caption.bold())
                        .labelStyle(.titleOnly)
                        .foregroundStyle(Color(red: 1.0, green: 0.85, blue: 0.4))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(.black.opacity(0.7), in: Capsule())
                } else {
                    Text("MAX")
                        .font(.caption2.bold())
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(.black.opacity(0.55), in: Capsule())
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(offer == nil)
    }
}

#Preview {
    LevelMapView(node: CampaignNode.all[0], onExit: {})
}
