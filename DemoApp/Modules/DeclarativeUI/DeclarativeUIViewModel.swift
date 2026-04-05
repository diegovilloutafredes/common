//
//  DeclarativeUIViewModel.swift
//  DemoApp
//

import Common

// MARK: - DeclarativeUIViewModelProtocol
protocol DeclarativeUIViewModelProtocol: ViewModel {
    var title: String { get }
}

// MARK: - DeclarativeUIViewModelImpl
final class DeclarativeUIViewModelImpl: DeclarativeUIViewModelProtocol {
    let title = "Declarative UI"
}
