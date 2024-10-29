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
public protocol AlertPresentable: AnyObject {
    var viewController: UIViewController? { get }
    func presentAlertView(type: AlertViewType, acceptAction: Handler<UIAlertAction>?, cancelAction: Handler<UIAlertAction>?)
    func presentAlertView(viewModel: AlertViewModel, onDismissRequested handler: CompletionHandler)
    func presentTextInputAlertView(title: String, message: String, placeholder: String, handler: @escaping Handler<String?>)
}

// MARK: - Default implementation where Self: UIViewController
extension AlertPresentable where Self: UIViewController {
    public var viewController: UIViewController? { self }
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

        viewController?.dismiss(animated: false) { self.viewController?.present(alertController, animated: true) }
    }

    public func presentAlertView(viewModel: AlertViewModel, onDismissRequested handler: CompletionHandler) {
        let view = AlertView(viewModel: viewModel)
        let vc = CustomAlertWireframe.createModule(view, onDismissRequested: viewModel.shouldHandleBackgroundClick ? handler : nil)
        viewController?.dismiss(animated: false) { self.viewController?.present(vc, animated: true) }
    }

    public func presentTextInputAlertView(title: String, message: String, placeholder: String, handler: @escaping Handler<String?>) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alert.addTextField { $0.placeholder = placeholder }

        alert.addAction(
            .init(
                title: .DefaultValues.Alerts.acceptActionTitle,
                style: .default,
                handler: { _ in
                    guard
                        let text = alert.textFields?.first?.text,
                        text.isNotEmpty
                    else {
                        handler(nil)
                        return
                    }

                    handler(text)
                }
            )
        )

        alert.addAction(
            .init(
                title: .DefaultValues.Alerts.cancelActionTitle,
                style: .cancel,
                handler: { _ in handler(nil) }
            )
        )

        viewController?.present(alert, animated: true)
    }
}

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
