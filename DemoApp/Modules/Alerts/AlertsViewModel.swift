//
//  AlertsViewModel.swift
//  DemoApp
//

import Common

// MARK: - AlertsViewModelProtocol
protocol AlertsViewModelProtocol: ViewModel {
    var title: String { get }
}

// MARK: - AlertsViewModelImpl
final class AlertsViewModelImpl: AlertsViewModelProtocol {
    let title = "Alerts & Feedback"
}
