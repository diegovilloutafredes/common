//
//  CoordinatorDemoWireframe.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - CoordinatorDemoWireframe
enum CoordinatorDemoWireframe {
    /// Returns the module's view controller alongside its view model — the
    /// coordinator keeps a weak reference to the latter and writes stats/events
    /// into it; the controller observes them.
    @MainActor static func createModule(
        onRequested: @escaping Handler<CoordinatorDemoViewModel.Requested>
    ) -> (viewController: UIViewController, viewModel: CoordinatorDemoViewModel) {
        let viewModel = CoordinatorDemoViewModel(onRequested: onRequested)
        let viewController = CoordinatorDemoViewController(viewModel: viewModel)
        return (viewController, viewModel)
    }
}
