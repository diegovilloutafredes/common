//
//  ExtensionsViewModel.swift
//  DemoApp
//

import Common

// MARK: - ExtensionsViewModelProtocol
protocol ExtensionsViewModelProtocol: ViewModel {
    var title: String { get }
}

// MARK: - ExtensionsViewModelImpl
final class ExtensionsViewModelImpl: ExtensionsViewModelProtocol {
    let title = "Extensions"
}
