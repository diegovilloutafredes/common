//
//  ListsWireframe.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - ListsWireframe
enum ListsWireframe {
    @MainActor static func createModule() -> UIViewController {
        ListsViewController(viewModel: ListsViewModel())
    }
}
