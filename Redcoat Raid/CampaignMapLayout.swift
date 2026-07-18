import CoreGraphics

/// Shared geometry for fitting the campaign map's safe rect onto a screen
/// of arbitrary size, used by both `Renderer` (to decide what to sample)
/// and the SwiftUI HUD (to position tappable nodes on top of it). Keeping
/// this in one place guarantees the two stay pixel-for-pixel in sync.
enum CampaignMapLayout {
    struct Crop {
        /// The sub-rect of the source image to display, in the image's
        /// own pixel coordinates.
        var rect: CGRect

        /// Whether the content is rotated 90° to keep it landscape-
        /// oriented within a portrait-shaped view.
        var rotated: Bool
    }

    /// Computes the sub-rect of `imageSize` (and rotation) that should
    /// fill a view of `viewSize` while always displaying in a landscape
    /// orientation.
    ///
    /// The result always contains `safeRect` in its entirety. `viewSize`
    /// is treated as landscape no matter its actual orientation — this
    /// app is landscape-only, but iPadOS can still hand it a portrait-
    /// shaped drawable (a resized multitasking window, or the device
    /// simply rotated), so rather than letterboxing or cropping into
    /// `safeRect` in that case, the crop is computed as if the view were
    /// landscape, and `rotated` tells the caller to rotate the content
    /// 90° to fill the portrait-shaped view instead.
    static func makeCrop(
        imageSize: CGSize,
        safeRect: CGRect,
        viewSize: CGSize
    ) -> Crop {
        let rotated = viewSize.height > viewSize.width

        // The "long side over short side" ratio, treating the view as
        // landscape no matter its actual orientation.
        let viewAspect = rotated
            ? viewSize.height / viewSize.width
            : viewSize.width / viewSize.height

        let safeAspect = safeRect.width / safeRect.height

        var cropWidth: CGFloat
        var cropHeight: CGFloat

        if viewAspect > safeAspect {
            // The view is proportionally wider than the safe rect
            // (typical iPhone landscape) — widen the crop, revealing more
            // of the image's left and right.
            cropHeight = safeRect.height
            cropWidth = cropHeight * viewAspect
        } else {
            // The view is proportionally taller/narrower than the safe
            // rect (typical iPad landscape) — heighten the crop, revealing
            // more of the image's top and bottom.
            cropWidth = safeRect.width
            cropHeight = cropWidth / viewAspect
        }

        // The crop can never exceed the image's actual pixel bounds —
        // there's no image data beyond its edges. If it's clamped here,
        // the source image doesn't have enough bleed around safeRect for
        // this view's aspect ratio, and the image will be very slightly
        // stretched on that axis rather than cropping into safeRect.
        assert(
            cropWidth <= imageSize.width && cropHeight <= imageSize.height,
            "\(CampaignMapAsset.imageName) doesn't have enough bleed " +
            "around safeRect to aspect-fill this view without " +
            "stretching. Extend the artwork's margins to fix this."
        )

        cropWidth = min(cropWidth, imageSize.width)
        cropHeight = min(cropHeight, imageSize.height)

        // Center the crop on safeRect, then shift (never shrink) it back
        // inside the image bounds if that pushed it past an edge.
        var cropOriginX = safeRect.midX - cropWidth / 2
        var cropOriginY = safeRect.midY - cropHeight / 2

        cropOriginX = min(max(cropOriginX, 0), imageSize.width - cropWidth)
        cropOriginY = min(max(cropOriginY, 0), imageSize.height - cropHeight)

        return Crop(
            rect: CGRect(
                x: cropOriginX,
                y: cropOriginY,
                width: cropWidth,
                height: cropHeight
            ),
            rotated: rotated
        )
    }

    /// Converts a point in the source image's pixel space (e.g. a
    /// campaign node's marker position) into a point within a view of
    /// `viewSize`, using the same crop and rotation the Metal renderer
    /// uses — so overlay content tracks the rendered image exactly.
    static func viewPoint(
        forImagePoint imagePoint: CGPoint,
        imageSize: CGSize,
        safeRect: CGRect,
        viewSize: CGSize
    ) -> CGPoint {
        let crop = makeCrop(
            imageSize: imageSize,
            safeRect: safeRect,
            viewSize: viewSize
        )

        // Fraction across the crop rect, 0...1 on each axis.
        let fractionX = (imagePoint.x - crop.rect.minX) / crop.rect.width
        let fractionY = (imagePoint.y - crop.rect.minY) / crop.rect.height

        guard crop.rotated else {
            return CGPoint(
                x: fractionX * viewSize.width,
                y: fractionY * viewSize.height
            )
        }

        // Inverse of the vertex shader's corner remap
        // (u, v) -> (v, 1 - u): solving screenFraction = (sx, sy) from
        // (fractionX, fractionY) = (sy, 1 - sx) gives sx = 1 - fractionY,
        // sy = fractionX.
        return CGPoint(
            x: (1 - fractionY) * viewSize.width,
            y: fractionX * viewSize.height
        )
    }
}
