//
//  NetworkingWireframe.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - NetworkingWireframe
enum NetworkingWireframe {
    @MainActor static func createModule() -> UIViewController {
        NetworkingViewController(viewModel: NetworkingViewModel())
    }
}
