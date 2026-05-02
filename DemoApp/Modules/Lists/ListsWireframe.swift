//
//  ListsWireframe.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - ListsWireframe
enum ListsWireframe {
    @MainActor static func createModule() -> UIViewController {
        let viewModel = ListsViewModel()
        return ListsViewController(viewModel: viewModel)
            .with { viewModel.view = $0 }
    }
}
