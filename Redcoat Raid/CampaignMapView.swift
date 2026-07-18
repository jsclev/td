import SwiftUI

/// The main campaign map screen: the Metal-rendered map with tappable
/// campaign nodes overlaid in SwiftUI.
///
/// Node positions are recomputed from `geometry.size` on every layout
/// pass, using the exact same crop math the Metal renderer uses (see
/// `CampaignMapLayout`), so they track the rendered map regardless of the
/// device's aspect ratio, orientation, or multitasking window size.
@available(iOS 26.0, *)
struct CampaignMapView: View {
    var onSelectNode: (CampaignNode) -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                CampaignMapMetalView()

                ForEach(CampaignNode.all) { node in
                    CampaignNodeButton(node: node) {
                        onSelectNode(node)
                    }
                    .position(
                        CampaignMapLayout.viewPoint(
                            forImagePoint: node.imagePosition,
                            imageSize: CampaignMapAsset.imageSize,
                            safeRect: CampaignMapAsset.safeRect,
                            viewSize: geometry.size
                        )
                    )
                }
            }
        }
        .ignoresSafeArea()
        .persistentSystemOverlays(.hidden)
    }
}

/// A tappable hotspot over a campaign node's painted badge on the map.
///
/// The artwork already draws the numbered badge, so this stays nearly
/// invisible and just supplies a generously-sized hit target plus tap
/// feedback — restyle freely once the interaction design firms up.
private struct CampaignNodeButton: View {
    var node: CampaignNode
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Circle()
                .fill(Color.white.opacity(0.001))
                .frame(width: 64, height: 64)
        }
        .buttonStyle(CampaignNodeButtonStyle())
        .accessibilityLabel(node.title)
    }
}

private struct CampaignNodeButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 3)
                    .opacity(configuration.isPressed ? 0.9 : 0)
            )
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

#Preview {
    CampaignMapView(onSelectNode: { _ in })
}
