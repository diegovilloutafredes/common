//
//  ComponentsWireframe.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - ComponentsWireframe
enum ComponentsWireframe {
    @MainActor
    static func createModule(onRequested: @escaping Handler<ComponentsViewModel.Requested>) -> UIViewController {
        ComponentsViewController(viewModel: ComponentsViewModel(onRequested: onRequested))
    }
}
