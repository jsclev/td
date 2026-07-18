import CoreGraphics

/// A tappable campaign event on the main campaign map.
struct CampaignNode: Identifiable {
    var id: Int
    var title: String

    /// The node's marker center, in the campaign map image's own pixel
    /// coordinates (see `CampaignMapAsset.imageSize`).
    var imagePosition: CGPoint
}

extension CampaignNode {
    /// Hand-picked from the painted badge centers in
    /// `redcoat_raid_264ppi`. Update these if the artwork changes.
    static let all: [CampaignNode] = [
        CampaignNode(
            id: 1,
            title: "Lexington & Concord",
            imagePosition: CGPoint(x: 1776, y: 371)
        )
    ]
}
