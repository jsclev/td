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
enum RadialMenu {
    static let radius: CGFloat = 74.8
    static let itemDiameter: CGFloat = 58
    /// Item angle by ring position: index 0 is straight up, then clockwise.
    static func angle(index: Int, count: Int) -> Angle {
        .degrees(-90 + Double(index) * 360 / Double(count))
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

    init(node: CampaignNode, onExit: @escaping () -> Void) {
        self.node = node
        self.onExit = onExit
        _runner = StateObject(wrappedValue: LevelRunner(
            levelInfoID: node.levelInfoID,
            mapImageSize: node.mapImageSize
        ))
    }

    var body: some View {
        GeometryReader { geometry in
            content(in: geometry.size)
        }
        .ignoresSafeArea()
        .persistentSystemOverlays(.hidden)
        .onAppear { runner.start() }
        .onDisappear { runner.stop() }
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
                    let towerHeight = projection.viewLength(runner.towerHeightInImagePixels)
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

            hud
        }
    }

    /// Full-screen transparent layer: tapping anywhere else closes the menu.
    private func dismissCatcher(viewSize: CGSize) -> some View {
        Color.black.opacity(0.001)
            .frame(width: viewSize.width, height: viewSize.height)
            .onTapGesture { runner.dismissMenu() }
    }

    /// The build ring: one circular icon per tower kind, evenly spaced around
    /// the slot. Positions derive from `TowerKind.allCases.count`.
    private func radialBuildMenu(around center: CGPoint) -> some View {
        let kinds = TowerKind.allCases
        return ForEach(Array(kinds.enumerated()), id: \.element) { index, kind in
            let angle = RadialMenu.angle(index: index, count: kinds.count)
            BuildMenuItem(kind: kind, isAvailable: runner.maxLevel(for: kind) >= 1) {
                runner.buildTower(kind)
            }
            .position(
                x: center.x + RadialMenu.radius * cos(angle.radians),
                y: center.y + RadialMenu.radius * sin(angle.radians)
            )
        }
    }

    /// The upgrade ring: a single item at the ring's fixed top position — the
    /// next tower level and its gold cost, or a maxed-out state when this
    /// level's unlock cap (level_tower_unlock) has been reached.
    private func upgradeMenu(for tower: PlacedTower, around center: CGPoint) -> some View {
        let angle = RadialMenu.angle(index: 0, count: 1)
        return UpgradeMenuItem(tower: tower, offer: runner.upgradeOffer) {
            runner.upgradeSelectedTower()
        }
        .position(
            x: center.x + RadialMenu.radius * cos(angle.radians),
            y: center.y + RadialMenu.radius * sin(angle.radians)
        )
    }

    private var hud: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button(action: onExit) {
                    Label("Campaign Map", systemImage: "chevron.left")
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.black.opacity(0.55), in: Capsule())
                        .foregroundStyle(.white)
                }
                Spacer()
            }

            Text(runner.status)
                .font(.footnote.monospaced())
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.black.opacity(0.55), in: RoundedRectangle(cornerRadius: 8))

            HStack(spacing: 10) {
                Button("Speed Up") {
                    runner.speedUp()
                }
                .buttonStyle(.borderedProminent)

                Text("×\(runner.speedMultiplier)")
                    .font(.footnote.monospaced())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.black.opacity(0.55), in: Capsule())
            }

            Spacer()
        }
        .padding(20)
    }
}

/// One choice in the radial build menu: a circular icon (the tower's sprite
/// when unlocked on this level, the padlock otherwise) with a label below.
private struct BuildMenuItem: View {
    let kind: TowerKind
    let isAvailable: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                ZStack {
                    Circle()
                        .fill(isAvailable ? Color(white: 0.96) : Color(white: 0.45))
                    Circle()
                        .strokeBorder(
                            isAvailable ? Color(red: 0.72, green: 0.55, blue: 0.2) : Color(white: 0.3),
                            lineWidth: 3
                        )

                    if isAvailable, let assetName = kind.assetName {
                        Image(assetName)
                            .resizable()
                            .scaledToFit()
                            .padding(7)
                    } else if !isAvailable {
                        // Locked on this level: the padlock IS the icon.
                        Image("lock_icon")
                            .resizable()
                            .scaledToFit()
                            .padding(13)
                    } else {
                        Image(systemName: kind.symbolName)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(Color(white: 0.65))
                    }
                }
                .frame(width: RadialMenu.itemDiameter, height: RadialMenu.itemDiameter)
                .opacity(isAvailable ? 1 : 0.75)

                Text(kind.label)
                    .font(.caption2.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.black.opacity(0.55), in: Capsule())
            }
        }
        .buttonStyle(.plain)
        .disabled(!isAvailable)
    }
}

/// The single item of the upgrade menu: the tower's sprite with the level it
/// would upgrade to, and the gold cost below — or a grey MAX state when the
/// tower has reached this level's unlock cap.
private struct UpgradeMenuItem: View {
    let tower: PlacedTower
    let offer: (nextLevel: Int, cost: Int)?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                ZStack {
                    Circle()
                        .fill(offer != nil ? Color(white: 0.96) : Color(white: 0.45))
                    Circle()
                        .strokeBorder(
                            offer != nil ? Color(red: 0.72, green: 0.55, blue: 0.2) : Color(white: 0.3),
                            lineWidth: 3
                        )

                    if let assetName = tower.kind.assetName {
                        Image(assetName)
                            .resizable()
                            .scaledToFit()
                            .padding(7)
                            .opacity(offer != nil ? 1 : 0.5)
                    }
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
        }
        .buttonStyle(.plain)
        .disabled(offer == nil)
    }
}

#Preview {
    LevelMapView(node: CampaignNode.all[0], onExit: {})
}
