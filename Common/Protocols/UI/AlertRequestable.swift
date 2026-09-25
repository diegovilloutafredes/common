//
//  AlertRequestable.swift
//

// MARK: - AlertRequestable
/// A protocol for objects that can request the presentation of an alert.
/// - Note: Legacy: in new modules an alert is a `ViewEvent` that the view controller presents; a coordinator calls `presentAlertView` directly (guide §6).
@MainActor
public protocol AlertRequestable: AnyObject {
    
    /// Requests the presentation of an alert with title and message.
    /// - Parameters:
    ///   - title: The title of the alert.
    ///   - message: The message body of the alert.
    ///   - handler: Optional completion handler for the accept action.
    ///   - cancelHandler: Optional completion handler for the cancel action.
    /// - Note: Legacy: new modules fire a `ViewEvent` and the view controller presents the alert (guide §6).
    func onPresentAlertRequested(title: String, message: String, handler: CompletionHandler, cancelHandler: CompletionHandler)
    
    /// Requests the presentation of a custom alert using a view model.
    /// - Parameter viewModel: The view model for the alert.
    /// - Note: Legacy: new modules fire a `ViewEvent` and the view controller presents the alert (guide §6).
    func onPresentAlertRequested(viewModel: AlertViewModel)
}

// MARK: - where Self: AlertPresentable
extension AlertRequestable where Self: AlertPresentable {
    public func onPresentAlertRequested(title: String = .DefaultValues.Alerts.title, message: String, handler: CompletionHandler = nil, cancelHandler: CompletionHandler = nil) {
        presentAlertView(
            type: .customAlert(title: title, message: message),
            acceptAction: handler.isNotNil ? { _ in handler?() } : nil,
            cancelAction: cancelHandler.isNotNil ? { _ in cancelHandler?() } : nil
        )
    }
}

// MARK: - where Self: BaseCoordinator
extension AlertRequestable where Self: BaseCoordinator {
    public func onPresentAlertRequested(viewModel: AlertViewModel) { presentAlertView(viewModel: viewModel, onDismissRequested: { [weak self] in self?.onDismissRequested() }) }
}
