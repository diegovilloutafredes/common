//
//  UtilitiesViewModel.swift
//  DemoApp
//

import Common

// MARK: - UtilitiesViewModelProtocol
protocol UtilitiesViewModelProtocol: ViewModel {
    var title: String { get }
}

// MARK: - UtilitiesViewModelImpl
final class UtilitiesViewModelImpl: UtilitiesViewModelProtocol {
    let title = "Utilities"
}
