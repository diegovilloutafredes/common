//
//  LocalAuthWireframe.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - LocalAuthWireframe
enum LocalAuthWireframe {
    static func createModule() -> UIViewController {
        let viewModel = LocalAuthViewModelImpl()
        return LocalAuthViewController(viewModel: viewModel)
    }
}
