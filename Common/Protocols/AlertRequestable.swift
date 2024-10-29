//
//  AlertRequestable.swift
//

// MARK: - AlertRequestable
public protocol AlertRequestable: AnyObject {
    func onPresentAlertRequested(title: String, message: String, handler: CompletionHandler, cancelHandler: CompletionHandler)
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
