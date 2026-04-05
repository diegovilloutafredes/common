//
//  StorageWireframe.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - StorageWireframe
enum StorageWireframe {
    static func createModule() -> UIViewController {
        let viewModel = StorageViewModelImpl()
        return StorageViewController(viewModel: viewModel)
    }
}
