//
//  AlertPresentable.swift
//

import UIKit

// MARK: - AlertViewType
public enum AlertViewType: Sendable {
    case emptyAlert
    case genericError
    case customAlert(title: String = .DefaultValues.Alerts.title, message: String = .empty)
}

// MARK: - AlertPresentable
/// A protocol for objects that can present various types of alert views.
@MainActor
public protocol AlertPresentable: AnyObject {
    
    /// Presents a standard alert view based on the specified type.
    /// - Parameters:
    ///   - type: The type of alert to present.
    ///   - acceptAction: Optional handler for the accept action.
    ///   - cancelAction: Optional handler for the cancel action.
    func presentAlertView(type: AlertViewType, acceptAction: Handler<UIAlertAction>?, cancelAction: Handler<UIAlertAction>?)
    
    /// Presents a custom alert view driven by a view model.
    /// - Parameters:
    ///   - viewModel: The view model providing the alert data.
    ///   - handler: A closure to be called when the alert is dismissed.
    func presentAlertView(viewModel: AlertViewModel, onDismissRequested handler: CompletionHandler)
}

// MARK: - Default implementation
extension AlertPresentable {
    @available(*, deprecated, message: "Use present, dismiss or presentAlertView, which honor presentationAnchor.")
    public var viewController: UIViewController? { presentationTarget }

    /// Where the default alerts go without a presentation anchor: the application's top-most controller.
    var presentationTarget: UIViewController? { UIApplication.shared.topMostViewController }

    public func presentAlertView(type: AlertViewType, acceptAction: ((UIAlertAction) -> Void)? = nil, cancelAction: ((UIAlertAction) -> Void)? = nil) {
        presentAlertView(
            type: type,
            acceptTitle: .DefaultValues.Alerts.acceptActionTitle,
            cancelTitle: .DefaultValues.Alerts.cancelActionTitle,
            acceptAction: acceptAction,
            cancelAction: cancelAction
        )
    }

    /// Presents the standard alert with the given button titles.
    ///
    /// The same alert as `presentAlertView(type:acceptAction:cancelAction:)`, whose default titles these default to.
    /// The cancel button appears only when `cancelAction` is given.
    /// - Parameters:
    ///   - type: The type of alert to present.
    ///   - acceptTitle: The accept button's title.
    ///   - cancelTitle: The cancel button's title.
    ///   - acceptAction: Optional handler for the accept action.
    ///   - cancelAction: Optional handler for the cancel action; without it there is no cancel button.
    public func presentAlertView(
        type: AlertViewType,
        acceptTitle: String = .DefaultValues.Alerts.acceptActionTitle,
        cancelTitle: String = .DefaultValues.Alerts.cancelActionTitle,
        acceptAction: ((UIAlertAction) -> Void)? = nil,
        cancelAction: ((UIAlertAction) -> Void)? = nil
    ) {
        var alertTitle: String = .empty
        var alertMessage: String = .empty

        switch type {
        case .genericError: alertMessage = .DefaultValues.Alerts.message
        case .customAlert(let title, let message):
            alertTitle = title
            alertMessage = message
        case .emptyAlert: break
        }

        let alertController = UIAlertController(
            title: alertTitle,
            message: alertMessage,
            preferredStyle: .alert
        )

        let acceptAlertAction = UIAlertAction(
            title: acceptTitle,
            style: .default,
            handler: acceptAction
        )

        alertController.addAction(acceptAlertAction)

        if let cancelAction = cancelAction {
            let cancelAlertAction = UIAlertAction(
                title: cancelTitle,
                style: .cancel,
                handler: cancelAction
            )

            alertController.addAction(cancelAlertAction)
        }

        applyDefaultAlertStyle(
            to: alertController,
            alertTitle: alertTitle,
            alertMessage: alertMessage
        )

        alertPresenter?.present(alertController, animated: true)
    }

    public func presentAlertView(viewModel: AlertViewModel, onDismissRequested handler: CompletionHandler) {
        let view = AlertView(viewModel: viewModel)
        let vc = CustomAlertWireframe.createModule(view, onDismissRequested: viewModel.shouldHandleBackgroundClick ? handler : nil)
        alertPresenter?.present(vc, animated: true)
    }

    /// The top-most controller the presentation anchor presents, or, without an anchor, `presentationTarget`.
    private var alertPresenter: UIViewController? {
        anchorController(of: self)?.topMostPresentedViewController ?? presentationTarget
    }
}

// MARK: - Convenience
extension AlertPresentable {
    func applyDefaultAlertStyle(to alertController: UIAlertController, alertTitle: String, alertMessage: String) {
        alertController.view.tintColor = .label

        let boldFont: UIFont = .boldSystemFont(ofSize: 17)

        let attributedTitle = NSMutableAttributedString(
            string: alertTitle,
            attributes: [
                .font: boldFont,
                .foregroundColor: UIColor.label
            ]
        )

        alertController.setValue(
            attributedTitle,
            forKey: "attributedTitle"
        )

        let regularFont: UIFont = .systemFont(ofSize: 13)

        let attributedMessage = NSMutableAttributedString(
            string: alertMessage,
            attributes: [
                .font: regularFont,
                .foregroundColor: UIColor.label
            ]
        )

        alertController.setValue(
            attributedMessage,
            forKey: "attributedMessage"
        )
    }
}
