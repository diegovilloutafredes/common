//
//  ObservationWireframe.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - ObservationWireframe
enum ObservationWireframe {
    @MainActor static func createModule() -> UIViewController {
        ObservationViewController(viewModel: ObservationViewModel())
    }
}
