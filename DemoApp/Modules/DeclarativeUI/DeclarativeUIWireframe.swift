//
//  DeclarativeUIWireframe.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - DeclarativeUIWireframe
enum DeclarativeUIWireframe {
    static func createModule() -> UIViewController {
        let viewModel = DeclarativeUIViewModelImpl()
        return DeclarativeUIViewController(viewModel: viewModel)
    }
}
