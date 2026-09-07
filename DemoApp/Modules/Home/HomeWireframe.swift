//
//  HomeWireframe.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - HomeWireframe
enum HomeWireframe {
    @MainActor static func createModule(onRequested: @escaping Handler<HomeViewModel.Requested>) -> UIViewController {
        HomeViewController(viewModel: HomeViewModel(onRequested: onRequested))
    }
}
