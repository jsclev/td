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
    static let imageName = "main_campaign_map_15_locations_v12_labels_restored"

    /// The image's actual pixel dimensions in Assets.xcassets.
    static let imageSize = CGSize(width: 3116, height: 2020)

    /// The rectangle, in the image's own pixel coordinates, that must
    /// always be fully visible on screen. Expanded to the MAXIMUM both
    /// device coverage limits allow (width < 4:3 iPad's 2693, height <
    /// 19.5:9 iPhone's 1433) so the outermost labels get all available
    /// breathing room from the screen edges: ~30pt horizontally on iPad,
    /// ~5pt vertically on iPhone. More margin than this requires taller
    /// artwork or labels moved inward — the art is exactly as tall as
    /// full-bleed on 19.5:9 iPhones permits. The title card (top-left)
    /// remains outside as decorative bleed.
    static let safeRectOrigin = CGPoint(x: 187, y: 379)
    static let safeRectSize = CGSize(width: 2692, height: 1432)

    static var safeRect: CGRect {
        CGRect(origin: safeRectOrigin, size: safeRectSize)
    }
}
