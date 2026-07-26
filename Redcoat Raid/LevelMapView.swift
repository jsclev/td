import SwiftUI

/// Maps points from the level art's pixel space onto the screen, anchored to
/// the level's playable rect: the map is scaled uniformly so the playable rect
/// exactly fits the screen (never clipped in either axis) and its centre sits
/// at the screen's centre, horizontally and vertically. Art outside the
/// playable rect is bleed — it fills whatever the device's aspect ratio
/// reveals beyond the 16:9 rect, and clips off-screen where it doesn't.
struct LevelMapProjection {
    let imageSize: CGSize
    let playableRect: CGRect
    let viewSize: CGSize

    /// The largest uniform scale at which the playable rect still fits
    /// entirely within the view on both axes.
    var scale: CGFloat {
        min(viewSize.width / playableRect.width, viewSize.height / playableRect.height)
    }

    /// Screen position of the art's (0, 0), placed so the playable rect's
    /// centre lands exactly on the view's centre.
    private var origin: CGPoint {
        CGPoint(
            x: viewSize.width / 2 - playableRect.midX * scale,
            y: viewSize.height / 2 - playableRect.midY * scale
        )
    }

    /// Image-pixel point -> view point.
    func viewPoint(_ p: CGPoint) -> CGPoint {
        CGPoint(x: origin.x + p.x * scale, y: origin.y + p.y * scale)
    }

    /// Image-pixel length -> view length.
    func viewLength(_ l: CGFloat) -> CGFloat { l * scale }

    /// The full map image's on-screen frame size at this projection.
    var imageFrameSize: CGSize {
        CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
    }

    /// Where the full map image's centre lands on screen.
    var imageCenter: CGPoint {
        viewPoint(CGPoint(x: imageSize.width / 2, y: imageSize.height / 2))
    }
}

/// A single battle's level map: the painted map aspect-filled to the screen,
/// enemies walking the level's path, and Kingdom Rush-style building — tap a
/// tower slot and a radial menu of tower choices blooms around it; tap a choice
/// to build it on that slot. Path, speeds, and the timer live in `LevelRunner`.
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

            // The map, scaled so the playable rect exactly fits the screen and
            // centred on it. The art's bleed beyond the playable rect covers
            // whatever the device's aspect ratio reveals.
            Image(node.mapImageName)
                .resizable()
                .frame(width: projection.imageFrameSize.width,
                       height: projection.imageFrameSize.height)
                .position(projection.imageCenter)

            // Built towers.
            ForEach(runner.placedTowers) { tower in
                if let assetName = tower.kind.assetName {
                    let towerHeight = projection.viewLength(runner.towerHeightInImagePixels)
                    let basePoint = projection.viewPoint(tower.position)
                    Image(assetName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: towerHeight)
                        // Anchor the tower's base just past the platform centre
                        // so it reads as planted on the platform.
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
                    // Anchor the sprite's feet on the path, not its centre.
                    .position(x: footPoint.x, y: footPoint.y - spriteHeight / 2)
            }

            // Tap targets over empty tower-slot platforms.
            ForEach(Array(runner.slotPositions.enumerated()), id: \.offset) { index, slotPosition in
                if !runner.isSlotOccupied(index) {
                    Button {
                        runner.selectSlot(index)
                    } label: {
                        Circle()
                            .fill(Color.white.opacity(0.001))
                            .frame(width: 64, height: 64)
                    }
                    .position(projection.viewPoint(slotPosition))
                }
            }

            // Radial build menu around the selected slot.
            if let selectedSlot = runner.selectedSlotIndex,
               runner.slotPositions.indices.contains(selectedSlot) {
                // Full-screen catcher: tapping anywhere else dismisses the menu.
                Color.black.opacity(0.001)
                    .frame(width: viewSize.width, height: viewSize.height)
                    .onTapGesture {
                        runner.dismissMenu()
                    }

                let center = projection.viewPoint(runner.slotPositions[selectedSlot])
                radialBuildMenu(around: center)
            }

            hud
        }
    }

    /// The Kingdom Rush-style ring: one circular icon per tower kind, evenly
    /// spaced around the slot, starting at the top. Positions derive from
    /// `TowerKind.allCases.count`, so a fifth kind joins the ring automatically.
    private func radialBuildMenu(around center: CGPoint) -> some View {
        let kinds = TowerKind.allCases
        let menuRadius: CGFloat = 74.8   // 88 * 0.85 — ring diameter reduced 15%

        return ForEach(Array(kinds.enumerated()), id: \.element) { index, kind in
            let angle = Angle.degrees(-90 + Double(index) * 360 / Double(kinds.count))
            let x = center.x + menuRadius * cos(angle.radians)
            let y = center.y + menuRadius * sin(angle.radians)

            BuildMenuItem(kind: kind, isAvailable: runner.availableTowerKinds.contains(kind)) {
                runner.buildTower(kind)
            }
            .position(x: x, y: y)
        }
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
/// when it has art, an SF Symbol otherwise) with a label below. Unavailable
/// kinds render greyed out with a lock and don't respond to taps.
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
                    } else {
                        Image(systemName: kind.symbolName)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(Color(white: 0.65))
                    }

                    if !isAvailable {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(3)
                            .background(Color(white: 0.25), in: Circle())
                            .offset(x: 18, y: 18)
                    }
                }
                .frame(width: 58, height: 58)
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

#Preview {
    LevelMapView(node: CampaignNode.all[0], onExit: {})
}
