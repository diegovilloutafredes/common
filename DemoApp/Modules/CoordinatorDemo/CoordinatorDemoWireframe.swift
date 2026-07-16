//
//  CoordinatorDemoWireframe.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - CoordinatorDemoWireframe
enum CoordinatorDemoWireframe {
    /// Returns the module's view controller alongside its view model — the
    /// coordinator keeps a weak reference to the latter to push stats/events in.
    static func createModule(
        with delegate: CoordinatorDemoViewModelDelegate
    ) -> (viewController: UIViewController, viewModel: CoordinatorDemoViewModel) {
        let viewModel = CoordinatorDemoViewModel(delegate: delegate)
        let viewController = CoordinatorDemoViewController(viewModel: viewModel)
            .with { viewModel.view = $0 }
        return (viewController, viewModel)
    }
}
