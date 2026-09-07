//
//  FormsWireframe.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - FormsWireframe
enum FormsWireframe {
    @MainActor static func createModule() -> UIViewController {
        FormsViewController(viewModel: FormsViewModel())
    }
}
