//
//  UtilitiesWireframe.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - UtilitiesWireframe
enum UtilitiesWireframe {
    static func createModule() -> UIViewController {
        let viewModel = UtilitiesViewModelImpl()
        return UtilitiesViewController(viewModel: viewModel)
    }
}
