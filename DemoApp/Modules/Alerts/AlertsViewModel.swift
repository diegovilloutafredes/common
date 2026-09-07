//
//  AlertsViewModel.swift
//  DemoApp
//

import Common
import Observation

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
    /// A modal effect over this screen: the controller presents it from `updateContent()`.
    var event: ViewEvent<AlertsViewModel.Event>? { get }
    func showCustomAlert(style: CustomAlertStyle)
}

// MARK: - AlertsViewModel
@Observable @MainActor
final class AlertsViewModel {
    enum Event { case showCustomAlert(CustomAlertStyle) }

    let title = "Alerts & Feedback"
    private(set) var event: ViewEvent<Event>?
}

// MARK: - AlertsViewModelProtocol
extension AlertsViewModel: AlertsViewModelProtocol {
    func showCustomAlert(style: CustomAlertStyle) {
        event = .init(.showCustomAlert(style))
    }
}
