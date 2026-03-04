//
//  AlertViewModel.swift
//

import UIKit

// MARK: - AlertViewModel
// MARK: - AlertViewModel

/// Defines the requirements for an alert view model.
public protocol AlertViewModel: ViewModel {
    var backgroundColor: UIColor { get }
    var icon: UIImage? { get }
    var iconTintColor: UIColor { get }
    var title: String { get }
    var titleColor: UIColor { get }
    var attributedMessage: NSAttributedString { get }
    var messageAlignment: NSTextAlignment { get }
    var messageColor: UIColor { get }
    var actionButtonTitle: String { get }
    var cancelButtonTitle: String { get }
    var onAction: CompletionHandler { get }
    var onCancel: CompletionHandler { get }
    var shouldHandleBackgroundClick: Bool { get }
}

/// Default implementations for `AlertViewModel`.
extension AlertViewModel {
    public var backgroundColor: UIColor { .white }
    public var iconTintColor: UIColor { .black }
    public var titleColor: UIColor { .black }
    public var messageAlignment: NSTextAlignment { .center }
    public var messageColor: UIColor { .black }
}

// MARK: - AlertViewModelPayload

/// A concrete implementation of `AlertViewModel` used to pass data to the alert.
public struct AlertViewModelPayload {
    public let icon: UIImage?
    public let title: String
    public let attributedMessage: NSAttributedString
    public let actionButtonTitle: String
    public let cancelButtonTitle: String
    public let onAction: CompletionHandler
    public let onCancel: CompletionHandler
    public let shouldHandleBackgroundClick: Bool

    /// Initializes a new alert payload.
    /// - Parameters:
    ///   - icon: Optional icon image.
    ///   - title: Title text.
    ///   - attributedMessage: Message text as an attributed string.
    ///   - actionButtonTitle: Title for the primary action button.
    ///   - cancelButtonTitle: Title for the cancel button.
    ///   - onActionButtonPressedHandler: Handler for the primary action.
    ///   - onCancelButtonPressedHandler: Handler for the cancel action.
    ///   - shouldHandleBackgroundClick: Whether background tap dismisses the alert. Defaults to `true`.
    public init(icon: UIImage? = nil, title: String, attributedMessage: NSAttributedString, actionButtonTitle: String = .DefaultValues.Alerts.acceptActionTitle, cancelButtonTitle: String = .DefaultValues.Alerts.cancelActionTitle, onActionButtonPressedHandler: CompletionHandler, onCancelButtonPressedHandler: CompletionHandler = nil, shouldHandleBackgroundClick: Bool = true) {
        self.icon = icon
        self.title = title
        self.attributedMessage = attributedMessage
        self.actionButtonTitle = actionButtonTitle
        self.cancelButtonTitle = cancelButtonTitle
        self.onAction = onActionButtonPressedHandler
        self.onCancel = onCancelButtonPressedHandler
        self.shouldHandleBackgroundClick = shouldHandleBackgroundClick
    }
}

// MARK: - AlertViewModel
extension AlertViewModelPayload: AlertViewModel {}


// MARK: - ValueWithable
extension AlertViewModelPayload: ValueWithable {}
