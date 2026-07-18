import SwiftUI

/// Switches between the campaign map and whichever level map is active.
///
/// Deliberately not a `NavigationStack` — this is a fixed, chrome-free
/// game screen, not a document-style push/pop hierarchy.
@available(iOS 26.0, *)
struct RootView: View {
    @State private var selectedNode: CampaignNode?

    var body: some View {
        if let selectedNode {
            LevelMapView(node: selectedNode) {
                self.selectedNode = nil
            }
        } else {
            CampaignMapView { node in
                selectedNode = node
            }
        }
    }
}
