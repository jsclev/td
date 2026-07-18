import CoreGraphics

/// The campaign map artwork and the gameplay-safe rect within it.
///
/// Both the Metal renderer and the SwiftUI HUD need these same values to
/// stay in sync — the renderer to decide what to draw, the HUD to
/// position tappable nodes on top of it. The renderer independently reads
/// the real loaded texture's pixel size for its own drawing, but the HUD
/// has no texture to query, so `imageSize` must be kept in sync by hand
/// whenever the artwork is replaced (as must `safeRectOrigin` /
/// `safeRectSize`, which have no source of truth other than the art).
enum CampaignMapAsset {
    static let imageName = "redcoat_raid_264ppi"

    /// The image's actual pixel dimensions in Assets.xcassets.
    static let imageSize = CGSize(width: 3116, height: 2020)

    /// The rectangle, in the image's own pixel coordinates, that must
    /// always be fully visible on screen.
    static let safeRectOrigin = CGPoint(x: 345, y: 242)
    static let safeRectSize = CGSize(width: 2510, height: 1412)

    static var safeRect: CGRect {
        CGRect(origin: safeRectOrigin, size: safeRectSize)
    }
}
