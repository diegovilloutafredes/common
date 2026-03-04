//
//  AlertPresentable.swift
//

import UIKit

// MARK: - AlertViewType
public enum AlertViewType {
    case emptyAlert
    case genericError
    case customAlert(title: String = .DefaultValues.Alerts.title, message: String = .empty)
}

// MARK: - AlertPresentable
// MARK: - AlertPresentable
/// A protocol for objects that can present various types of alert views.
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
    public var viewController: UIViewController? { UIApplication.shared.topMostViewController }

    public func presentAlertView(type: AlertViewType, acceptAction: ((UIAlertAction) -> Void)? = nil, cancelAction: ((UIAlertAction) -> Void)? = nil) {
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
            title: .DefaultValues.Alerts.acceptActionTitle,
            style: .default,
            handler: acceptAction
        )

        alertController.addAction(acceptAlertAction)

        if let cancelAction = cancelAction {
            let cancelAlertAction = UIAlertAction(
                title: .DefaultValues.Alerts.cancelActionTitle,
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

        guard viewController is UIAlertController else {
            viewController?.present(
                alertController,
                animated: true
            )

            return
        }

        viewController?.present(alertController, animated: true)
    }

    public func presentAlertView(viewModel: AlertViewModel, onDismissRequested handler: CompletionHandler) {
        let view = AlertView(viewModel: viewModel)
        let vc = CustomAlertWireframe.createModule(view, onDismissRequested: viewModel.shouldHandleBackgroundClick ? handler : nil)
        viewController?.present(vc, animated: true)
    }
}

// MARK: - Convenience
extension AlertPresentable {
    private func applyDefaultAlertStyle(to alertController: UIAlertController, alertTitle: String, alertMessage: String) {
        alertController.view.tintColor = .black

        let boldFont: UIFont = .boldSystemFont(ofSize: 17)

        let attributedTitle = NSMutableAttributedString(
            string: alertTitle,
            attributes: [
                .font: boldFont,
                .foregroundColor: UIColor.black
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
                .foregroundColor: UIColor.black
            ]
        )

        alertController.setValue(
            attributedMessage,
            forKey: "attributedMessage"
        )
    }
}
