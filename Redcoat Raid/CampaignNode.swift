import CoreGraphics
import Foundation

/// A tappable campaign event on the main campaign map.
struct CampaignNode: Identifiable {
    var id: Int
    var title: String

    /// The node's marker center, in the campaign map image's own pixel
    /// coordinates (see `CampaignMapAsset.imageSize`).
    var imagePosition: CGPoint

    /// The tappable region on the campaign art, in image pixel coordinates:
    /// a rect spanning the painted badge AND its name/date label, so players
    /// can tap either. Projected to screen space by CampaignMapLayout.
    var tapRect: CGRect

    /// The `level_info.id` this node opens. Links the map badge to the row the
    /// level view loads its path, tower slots, and playable rect from.
    var levelInfoID: UUID?

    /// Asset-catalog image for the level's map, and its pixel dimensions —
    /// the coordinate space the level's paths, tower slots, and playable rect
    /// are authored in. Keep the size in sync if the art is replaced.
    var mapImageName: String
    var mapImageSize: CGSize

    /// Whether the campaign artwork has a painted badge at `imagePosition`.
    /// Nodes without one render a placeholder badge so they're discoverable
    /// until the art gains a painted badge.
    var hasPaintedBadge: Bool = true
}

extension CampaignNode {
    /// Badge centers measured from `main_campaign_map_15_locations_v12_labels_restored`,
    /// whose painted numbering matches the Main campaign's chronological order.
    /// Node ids match the painted badge numbers. These positions are also
    /// stored in the database (level_info.world_map_x/y).
    static let all: [CampaignNode] = [
        CampaignNode(
            id: 1,
            title: "Lexington & Concord",
            imagePosition: CGPoint(x: 2228, y: 495),
            tapRect: CGRect(x: 2180, y: 443, width: 532, height: 104),
            levelInfoID: UUID(uuidString: "be3cf809-f71e-4209-bc4d-8b25b0b5f2a0"),
            mapImageName: "level_001_lexington_and_concord",
            mapImageSize: CGSize(width: 1447, height: 1087)
        ),
        CampaignNode(
            id: 2,
            title: "Bunker Hill",
            imagePosition: CGPoint(x: 2342, y: 631),
            tapRect: CGRect(x: 2294, y: 580, width: 312, height: 104),
            levelInfoID: UUID(uuidString: "9d692af7-345d-419a-bc04-16112c3f0b74"),
            mapImageName: "level_002_bunker_hill",
            mapImageSize: CGSize(width: 1672, height: 941)
        ),
        CampaignNode(
            id: 3,
            title: "Great Bridge",
            imagePosition: CGPoint(x: 1567, y: 1231),
            tapRect: CGRect(x: 1516, y: 1180, width: 384, height: 102),
            levelInfoID: UUID(uuidString: "55a5d12d-3cea-475f-aa8d-125271a8a0c2"),
            mapImageName: "level_003_great_bridge",
            mapImageSize: CGSize(width: 1447, height: 1087)
        ),
        CampaignNode(
            id: 4,
            title: "Moore's Creek Bridge",
            imagePosition: CGPoint(x: 1371, y: 1466),
            tapRect: CGRect(x: 1322, y: 1414, width: 530, height: 104),
            levelInfoID: UUID(uuidString: "4cbeebf1-cd0c-4818-84b1-cb62f246d1ed"),
            mapImageName: "level_004_moores_creek_bridge",
            mapImageSize: CGSize(width: 1672, height: 941)
        ),
        CampaignNode(
            id: 5,
            title: "Dorchester Heights",
            imagePosition: CGPoint(x: 2353, y: 788),
            tapRect: CGRect(x: 2303, y: 736, width: 530, height: 104),
            levelInfoID: UUID(uuidString: "17914ebc-7052-490d-b606-afc1746da512"),
            mapImageName: "level_005_dorchester_heights",
            mapImageSize: CGSize(width: 1536, height: 1024)
        ),
        CampaignNode(
            id: 6,
            title: "Sullivan's Island",
            imagePosition: CGPoint(x: 1318, y: 1567),
            tapRect: CGRect(x: 1268, y: 1518, width: 530, height: 102),
            levelInfoID: UUID(uuidString: "35916460-914a-457b-beb9-1c5bfe95e61a"),
            mapImageName: "level_006_sullivans_island",
            mapImageSize: CGSize(width: 1536, height: 1024)
        ),
        CampaignNode(
            id: 7,
            title: "Long Island",
            imagePosition: CGPoint(x: 1957, y: 776),
            tapRect: CGRect(x: 1907, y: 724, width: 383, height: 104),
            levelInfoID: UUID(uuidString: "99633efd-f135-44fc-8248-b8635a6db957"),
            mapImageName: "level_007_long_island",
            mapImageSize: CGSize(width: 1672, height: 941)
        ),
        CampaignNode(
            id: 8,
            title: "Trenton",
            imagePosition: CGPoint(x: 1832, y: 943),
            tapRect: CGRect(x: 1782, y: 890, width: 308, height: 106),
            levelInfoID: UUID(uuidString: "537aba11-6201-4fe9-b789-36607de98e41"),
            mapImageName: "level_008_trenton",
            mapImageSize: CGSize(width: 1672, height: 941)
        ),
        CampaignNode(
            id: 9,
            title: "Princeton",
            imagePosition: CGPoint(x: 1599, y: 983),
            tapRect: CGRect(x: 1300, y: 930, width: 360, height: 104),
            levelInfoID: UUID(uuidString: "9c6679ab-c028-48ab-95b7-93318f37c1a9"),
            mapImageName: "level_009_princeton",
            mapImageSize: CGSize(width: 1447, height: 1087)
        ),
        CampaignNode(
            id: 10,
            title: "Fort Ann",
            imagePosition: CGPoint(x: 1748, y: 444),
            tapRect: CGRect(x: 1468, y: 394, width: 333, height: 109),
            levelInfoID: UUID(uuidString: "42e95fce-6da1-416d-bf69-24f70bb4dc52"),
            mapImageName: "level_010_fort_ann",
            mapImageSize: CGSize(width: 1536, height: 1024)
        ),
        CampaignNode(
            id: 11,
            title: "Saratoga",
            imagePosition: CGPoint(x: 1852, y: 623),
            tapRect: CGRect(x: 1572, y: 577, width: 338, height: 109),
            levelInfoID: UUID(uuidString: "549a67d9-f721-4cdf-8ba7-8916ba71b040"),
            mapImageName: "level_011_saratoga",
            mapImageSize: CGSize(width: 1536, height: 1024)
        ),
        CampaignNode(
            id: 12,
            title: "Kettle Creek",
            imagePosition: CGPoint(x: 753, y: 1553),
            tapRect: CGRect(x: 405, y: 1500, width: 400, height: 108),
            levelInfoID: UUID(uuidString: "33d900c6-c6ff-409a-973b-f09ddc8a6f6a"),
            mapImageName: "level_012_kettle_creek",
            mapImageSize: CGSize(width: 1536, height: 1024)
        ),
        CampaignNode(
            id: 13,
            title: "New Haven",
            imagePosition: CGPoint(x: 2083, y: 659),
            tapRect: CGRect(x: 1994, y: 480, width: 145, height: 230),
            levelInfoID: UUID(uuidString: "96170d0e-6983-47e0-bf80-93cd4c91ad3a"),
            mapImageName: "level_013_new_haven",
            mapImageSize: CGSize(width: 1536, height: 1024)
        ),
        CampaignNode(
            id: 14,
            title: "Savannah",
            imagePosition: CGPoint(x: 977, y: 1675),
            tapRect: CGRect(x: 675, y: 1624, width: 354, height: 116),
            levelInfoID: UUID(uuidString: "46157f59-b21b-4b03-9151-d404c6cd6d0b"),
            mapImageName: "level_014_savannah",
            mapImageSize: CGSize(width: 1536, height: 1024)
        ),
        CampaignNode(
            id: 15,
            title: "Siege of Charleston",
            imagePosition: CGPoint(x: 1329, y: 1748),
            tapRect: CGRect(x: 1280, y: 1697, width: 342, height: 103),
            levelInfoID: UUID(uuidString: "4ca73a47-98f6-41b6-815d-c2c797aa746e"),
            mapImageName: "level_014_siege_of_charleston",
            mapImageSize: CGSize(width: 1448, height: 1086)
        ),
    ]
}
