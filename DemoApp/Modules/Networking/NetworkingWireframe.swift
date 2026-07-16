//
//  NetworkingWireframe.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - NetworkingWireframe
enum NetworkingWireframe {
    static func createModule() -> UIViewController {
        let viewModel = NetworkingViewModel()
        return NetworkingViewController(viewModel: viewModel)
            .with { viewModel.view = $0 }
    }
}
