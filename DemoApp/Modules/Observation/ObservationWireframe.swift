//
//  ObservationWireframe.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - ObservationWireframe
enum ObservationWireframe {
    @MainActor static func createModule() -> UIViewController {
        let viewModel = ObservationViewModel()
        return ObservationViewController(viewModel: viewModel)
            .with { viewModel.view = $0 }
    }
}
