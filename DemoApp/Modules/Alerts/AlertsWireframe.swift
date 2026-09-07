//
//  AlertsWireframe.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - AlertsWireframe
enum AlertsWireframe {
    @MainActor static func createModule() -> UIViewController {
        AlertsViewController(viewModel: AlertsViewModel())
    }
}
