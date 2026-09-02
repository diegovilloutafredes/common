//
//  TypographyWireframe.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - TypographyWireframe
enum TypographyWireframe {
    @MainActor static func createModule() -> UIViewController {
        let viewModel = TypographyViewModel()
        return TypographyViewController(viewModel: viewModel)
    }
}
