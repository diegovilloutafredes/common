//
//  FormsWireframe.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - FormsWireframe
enum FormsWireframe {
    @MainActor static func createModule() -> UIViewController {
        let viewModel = FormsViewModel()
        return FormsViewController(viewModel: viewModel)
            .with { viewModel.view = $0 }
    }
}
