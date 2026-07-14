import UIKit
import Metal
import MetalKit

@available(iOS 26.0, *)
final class GameViewController: UIViewController {

    // MTKView's delegate is not something you should rely on to retain
    // the renderer, so keep a strong reference here.
    private var renderer: Renderer?

    override func loadView() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is unavailable on this device.")
        }

        guard device.supportsFamily(.metal4) else {
            fatalError("This device doesn't support Metal 4.")
        }

        let metalView = MTKView(
            frame: .zero,
            device: device
        )

        metalView.autoresizingMask = [
            .flexibleWidth,
            .flexibleHeight
        ]

        metalView.colorPixelFormat = .bgra8Unorm_srgb
        metalView.depthStencilPixelFormat = .invalid

        metalView.clearColor = MTLClearColor(
            red: 0.02,
            green: 0.03,
            blue: 0.05,
            alpha: 1.0
        )

        /*
         The campaign map is static, so render only when requested.
         For an animated game, use:

             metalView.isPaused = false
             metalView.enableSetNeedsDisplay = false
        */
        metalView.isPaused = true
        metalView.enableSetNeedsDisplay = true

        do {
            let renderer = try Renderer(
                view: metalView,
                imageName: "redcoat_raid_264ppi"
            )

            /*
             renderer.safeRectOrigin and renderer.safeRectSize default to
             the gameplay-safe rect within redcoat_raid_264ppi (345, 242,
             2510, 1412). Override them here if that ever changes:

             renderer.safeRectOrigin = CGPoint(x: 345, y: 242)
             renderer.safeRectSize = CGSize(width: 2510, height: 1412)
            */

            metalView.delegate = renderer
            self.renderer = renderer
        } catch {
            fatalError(
                "Metal renderer creation failed: "
                + error.localizedDescription
            )
        }

        view = metalView
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Causes one frame to be drawn for the static campaign map.
        (view as? MTKView)?.setNeedsDisplay()
    }

    override var shouldAutorotate: Bool {
        true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .landscape
    }
}
