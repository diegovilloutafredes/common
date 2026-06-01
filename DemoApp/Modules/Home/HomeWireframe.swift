//
//  HomeWireframe.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - HomeWireframe
enum HomeWireframe {
    @MainActor static func createModule(coordinator: HomeCoordinatorProtocol) -> UIViewController {
        let viewModel = HomeViewModel(coordinator: coordinator)
        return HomeViewController(viewModel: viewModel)
            .with { viewModel.view = $0 }
    }
}
