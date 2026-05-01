//
//  HomeWireframe.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - HomeWireframe
enum HomeWireframe {
    @MainActor static func createModule(coordinator: AppCoordinator) -> UIViewController {
        let viewModel = HomeViewModel(coordinator: coordinator)
        return HomeViewController(viewModel: viewModel)
            .with { viewModel.view = $0 }
    }
}
