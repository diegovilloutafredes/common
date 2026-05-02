//
//  AlertsViewModel.swift
//  DemoApp
//

import Common

// MARK: - CustomAlertStyle
enum CustomAlertStyle {
    case basic
    case withCancel
    case noDismissOnBackground
    case customContent
}

// MARK: - AlertsViewModelProtocol
@MainActor
protocol AlertsViewModelProtocol: ViewModel {
    var title: String { get }
    func onShowCustomAlertRequested(style: CustomAlertStyle)
}

// MARK: - AlertsViewModel
@MainActor
final class AlertsViewModel {
    let title = "Alerts & Feedback"
    private weak var coordinator: AlertsCoordinatorProtocol?

    init(coordinator: AlertsCoordinatorProtocol) {
        self.coordinator = coordinator
    }
}

// MARK: - AlertsViewModelProtocol
extension AlertsViewModel: AlertsViewModelProtocol {
    func onShowCustomAlertRequested(style: CustomAlertStyle) {
        coordinator?.showCustomAlert(style: style)
    }
}
