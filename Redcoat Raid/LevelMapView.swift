import SwiftUI

/// Maps points from the level art's pixel space onto a view that shows the art
/// aspect-filled (matching SwiftUI's `.scaledToFill()`): scale by the larger
/// axis ratio and centre. Used to place path-driven sprites over the map.
struct LevelMapProjection {
    let imageSize: CGSize
    let viewSize: CGSize

    var scale: CGFloat {
        max(viewSize.width / imageSize.width, viewSize.height / imageSize.height)
    }

    private var origin: CGPoint {
        CGPoint(
            x: (viewSize.width - imageSize.width * scale) / 2,
            y: (viewSize.height - imageSize.height * scale) / 2
        )
    }

    /// Image-pixel point -> view point.
    func viewPoint(_ p: CGPoint) -> CGPoint {
        CGPoint(x: origin.x + p.x * scale, y: origin.y + p.y * scale)
    }

    /// Image-pixel length -> view length.
    func viewLength(_ l: CGFloat) -> CGFloat { l * scale }
}

/// A single battle's level map: the painted map aspect-filled to the screen,
/// with a Loyalist Militia sprite walking the level's path. Path, sprite speed,
/// and the timer all come from `LevelRunner`.
struct LevelMapView: View {
    var node: CampaignNode
    var onExit: () -> Void

    @StateObject private var runner: LevelRunner

    init(node: CampaignNode, onExit: @escaping () -> Void) {
        self.node = node
        self.onExit = onExit
        _runner = StateObject(wrappedValue: LevelRunner(levelInfoID: node.levelInfoID))
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
        let projection = LevelMapProjection(imageSize: runner.mapImageSize, viewSize: viewSize)

        return ZStack(alignment: .topLeading) {
            Color.black

            Image("lexington_and_concord")
                .resizable()
                .scaledToFill()
                .frame(width: viewSize.width, height: viewSize.height)
                .clipped()

            if let position = runner.spritePosition {
                let spriteHeight = projection.viewLength(runner.spriteHeightInImagePixels)
                let footPoint = projection.viewPoint(position)
                Image("loyalist_militia")
                    .resizable()
                    .scaledToFit()
                    .frame(height: spriteHeight)
                    // Anchor the sprite's feet on the path, not its centre.
                    .position(x: footPoint.x, y: footPoint.y - spriteHeight / 2)
            }

            hud
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

            Spacer()
        }
        .padding(20)
    }
}

#Preview {
    LevelMapView(node: CampaignNode.all[0], onExit: {})
}
