import CoreGraphics
import Foundation

/// A tappable campaign event on the main campaign map.
struct CampaignNode: Identifiable {
    var id: Int
    var title: String

    /// The node's marker center, in the campaign map image's own pixel
    /// coordinates (see `CampaignMapAsset.imageSize`).
    var imagePosition: CGPoint

    /// The `level_info.id` this node opens. Links the map badge to the row the
    /// level view loads its path, tower slots, and enemy roster from.
    var levelInfoID: UUID?
}

extension CampaignNode {
    /// Hand-picked from the painted badge centers in
    /// `redcoat_raid_264ppi`. Update these if the artwork changes.
    static let all: [CampaignNode] = [
        CampaignNode(
            id: 1,
            title: "Lexington & Concord",
            imagePosition: CGPoint(x: 1776, y: 371),
            levelInfoID: UUID(uuidString: "be3cf809-f71e-4209-bc4d-8b25b0b5f2a0")
        )
    ]
}
