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
    /// level view loads its path, tower slots, and playable rect from.
    var levelInfoID: UUID?

    /// Asset-catalog image for the level's map, and its pixel dimensions —
    /// the coordinate space the level's paths, tower slots, and playable rect
    /// are authored in. Keep the size in sync if the art is replaced.
    var mapImageName: String
    var mapImageSize: CGSize
}

extension CampaignNode {
    /// Hand-picked from the painted badge centers in
    /// `redcoat_raid_264ppi`. Update these if the artwork changes.
    static let all: [CampaignNode] = [
        CampaignNode(
            id: 1,
            title: "Lexington & Concord",
            imagePosition: CGPoint(x: 1776, y: 371),
            levelInfoID: UUID(uuidString: "be3cf809-f71e-4209-bc4d-8b25b0b5f2a0"),
            mapImageName: "lexington_and_concord",
            mapImageSize: CGSize(width: 1447, height: 1087)
        ),
        CampaignNode(
            id: 2,
            title: "Bunker Hill",
            imagePosition: CGPoint(x: 1927, y: 443),
            levelInfoID: UUID(uuidString: "9d692af7-345d-419a-bc04-16112c3f0b74"),
            mapImageName: "level_002_bunker_hill",
            mapImageSize: CGSize(width: 1672, height: 941)
        ),
    ]
}
