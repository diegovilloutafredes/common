//
//  ExtensionsWireframe.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - ExtensionsWireframe
enum ExtensionsWireframe {
    static func createModule() -> UIViewController {
        let viewModel = ExtensionsViewModelImpl()
        return ExtensionsViewController(viewModel: viewModel)
    }
}
