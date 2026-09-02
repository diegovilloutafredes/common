//
//  CameraWireframe.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - CameraWireframe
enum CameraWireframe {
    @MainActor static func createModule() -> UIViewController {
        let viewModel = CameraViewModelImpl()
        return CameraViewController(viewModel: viewModel)
    }
}
