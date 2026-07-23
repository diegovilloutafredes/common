//
//  ComponentsWireframe.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - ComponentsWireframe
enum ComponentsWireframe {
    @MainActor
    static func createModule(onGoBack: @escaping Action) -> UIViewController {
        let viewModel = ComponentsViewModel(onGoBack: onGoBack)
        return ComponentsViewController(viewModel: viewModel)
            .with { viewModel.view = $0 }
    }
}
