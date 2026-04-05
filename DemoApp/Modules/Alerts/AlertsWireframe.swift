//
//  AlertsWireframe.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - AlertsWireframe
enum AlertsWireframe {
    static func createModule() -> UIViewController {
        let viewModel = AlertsViewModelImpl()
        return AlertsViewController(viewModel: viewModel)
    }
}
