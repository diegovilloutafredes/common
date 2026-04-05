//
//  HomeWireframe.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - HomeWireframe
enum HomeWireframe {
    static func createModule(coordinator: AppCoordinator) -> UIViewController {
        let viewModel = HomeViewModel(coordinator: coordinator)
        let vc = HomeViewController(viewModel: viewModel)
        viewModel.view = vc
        return vc
    }
}
