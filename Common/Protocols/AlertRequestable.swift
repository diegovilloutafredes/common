//
//  AlertRequestable.swift
//

// MARK: - AlertRequestable
// MARK: - AlertRequestable
/// A protocol for objects that can request the presentation of an alert.
public protocol AlertRequestable: AnyObject {
    
    /// Requests the presentation of an alert with title and message.
    /// - Parameters:
    ///   - title: The title of the alert.
    ///   - message: The message body of the alert.
    ///   - handler: Optional completion handler for the accept action.
    ///   - cancelHandler: Optional completion handler for the cancel action.
    func onPresentAlertRequested(title: String, message: String, handler: CompletionHandler, cancelHandler: CompletionHandler)
    
    /// Requests the presentation of a custom alert using a view model.
    /// - Parameter viewModel: The view model for the alert.
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
    public func onPresentAlertRequested(viewModel: AlertViewModel) { presentAlertView(viewModel: viewModel, onDismissRequested: onDismissRequested) }
}
