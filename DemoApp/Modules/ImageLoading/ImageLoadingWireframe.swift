import Common
import UIKit

// MARK: - ImageLoadingWireframe

enum ImageLoadingWireframe {
    @MainActor static func createModule() -> UIViewController {
        let viewModel = ImageLoadingViewModel()
        return ImageLoadingViewController(viewModel: viewModel)
            .with { viewModel.view = $0 }
    }
}
