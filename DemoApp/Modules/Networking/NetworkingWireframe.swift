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
        let vc = NetworkingViewController(viewModel: viewModel)
        viewModel.view = vc
        return vc
    }
}
