//
//  AlertsWireframe.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - AlertsWireframe
enum AlertsWireframe {
    @MainActor static func createModule(coordinator: AlertsCoordinatorProtocol) -> UIViewController {
        let viewModel = AlertsViewModel(coordinator: coordinator)
        return AlertsViewController(viewModel: viewModel)
    }
}
