//
//  TypographyWireframe.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - TypographyWireframe
enum TypographyWireframe {
    static func createModule() -> UIViewController {
        let viewModel = TypographyViewModel()
        return TypographyViewController(viewModel: viewModel)
            .with { viewModel.view = $0; viewModel.delegate = $0 }
    }
}
