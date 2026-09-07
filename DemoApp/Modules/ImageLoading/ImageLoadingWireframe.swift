import Common
import UIKit

// MARK: - ImageLoadingWireframe

enum ImageLoadingWireframe {
    @MainActor static func createModule() -> UIViewController {
        ImageLoadingViewController(viewModel: ImageLoadingViewModel())
    }
}
