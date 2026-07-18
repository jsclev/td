import SwiftUI

/// Placeholder for a single battle's level map, shown after tapping a
/// campaign node. Replace the body with the actual level map renderer.
struct LevelMapView: View {
    var node: CampaignNode
    var onExit: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {
                Text(node.title)
                    .font(.system(size: 40, weight: .bold, design: .serif))
                    .foregroundStyle(.white)

                Text("Level map goes here.")
                    .foregroundStyle(.white.opacity(0.7))

                Button("Return to Campaign Map", action: onExit)
                    .buttonStyle(.borderedProminent)
            }
        }
        .ignoresSafeArea()
        .persistentSystemOverlays(.hidden)
    }
}

#Preview {
    LevelMapView(node: CampaignNode.all[0], onExit: {})
}
