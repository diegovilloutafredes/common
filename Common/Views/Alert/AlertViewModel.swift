//
//  AlertViewModel.swift
//

import UIKit

// MARK: - AlertViewModel
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
    var onActionButtonPressedHandler: CompletionHandler { get }
    var onCancelButtonPressedHandler: CompletionHandler { get }
    var shouldHandleBackgroundClick: Bool { get }
}

extension AlertViewModel {
    public var backgroundColor: UIColor { .white }
    public var iconTintColor: UIColor { .black }
    public var titleColor: UIColor { .black }
    public var messageAlignment: NSTextAlignment { .center }
    public var messageColor: UIColor { .black }
    public var actionButtonTitle: String { .DefaultValues.Alerts.acceptActionTitle }
    public var cancelButtonTitle: String { .DefaultValues.Alerts.cancelActionTitle }
}

// MARK: - AlertViewModelPayload
public struct AlertViewModelPayload {
    public let icon: UIImage?
    public let title: String
    public let attributedMessage: NSAttributedString
    public let onActionButtonPressedHandler: CompletionHandler
    public let onCancelButtonPressedHandler: CompletionHandler
    public let shouldHandleBackgroundClick: Bool

    public init(icon: UIImage? = nil, title: String, attributedMessage: NSAttributedString, onActionButtonPressedHandler: CompletionHandler, onCancelButtonPressedHandler: CompletionHandler = nil, shouldHandleBackgroundClick: Bool = true) {
        self.icon = icon
        self.title = title
        self.attributedMessage = attributedMessage
        self.onActionButtonPressedHandler = onActionButtonPressedHandler
        self.onCancelButtonPressedHandler = onCancelButtonPressedHandler
        self.shouldHandleBackgroundClick = shouldHandleBackgroundClick
    }
}

// MARK: - AlertViewModel
extension AlertViewModelPayload: AlertViewModel {}


// MARK: - ValueWithable
extension AlertViewModelPayload: ValueWithable {}
