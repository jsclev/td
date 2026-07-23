import SwiftUI

/// Switches between the campaign map and whichever level map is active.
///
/// Deliberately not a `NavigationStack` — this is a fixed, chrome-free
/// game screen, not a document-style push/pop hierarchy.
@available(iOS 26.0, *)
struct RootView: View {
    // TEMPORARY: launch straight into the Lexington & Concord level, bypassing
    // the campaign map. Revert this back to `= nil` to restore normal entry.
    // (The level's "Campaign Map" button still returns to the campaign map.)
    @State private var selectedNode: CampaignNode? = CampaignNode.all.first

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
