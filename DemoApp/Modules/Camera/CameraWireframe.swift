//
//  CameraWireframe.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - CameraWireframe
enum CameraWireframe {
    static func createModule() -> UIViewController {
        let viewModel = CameraViewModelImpl()
        return CameraViewController(viewModel: viewModel)
            .with { viewModel.view = $0 }
    }
}
