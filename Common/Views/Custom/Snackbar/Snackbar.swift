//
//  Snackbar.swift
//

import UIKit

// MARK: - Snackbar
// MARK: - Snackbar

/// A utility for displaying snackbar notifications.
public enum Snackbar {
    
    /// Defines the duration of the snackbar.
    public enum Duration {
        case custom(TimeInterval)
        case short
        case medium
        case long

        var asTimeInterval: TimeInterval {
            switch self {
            case .custom(let timeInterval): timeInterval
            case .short: Self.custom(1).asTimeInterval
            case .medium: Self.custom(3).asTimeInterval
            case .long: Self.custom(5).asTimeInterval
            }
        }
    }

    // MARK: - SnackbarPayload
    
    /// A view model representing the data for a snackbar.
    public struct ViewModel: SnackbarViewModel {
        let message: String
        let messageFont: UIFont
        let duration: TimeInterval
        let actionTitle: String?
        let actionFont: UIFont
        let onAction: CompletionHandler
        let onDismiss: CompletionHandler

        /// Initializes a new snackbar view model.
        /// - Parameters:
        ///   - message: The message to display.
        ///   - messageFont: The font of the message.
        ///   - duration: The duration of the snackbar.
        ///   - actionTitle: The title of the action button (optional).
        ///   - actionFont: The font of the action button.
        ///   - onAction: Handler for the action button tap.
        ///   - onDismiss: Handler for the snackbar dismissal.
        public init(message: String, messageFont: UIFont = .systemFont(ofSize: 14), duration: Duration = .medium, actionTitle: String? = nil, actionFont: UIFont = .systemFont(ofSize: 12, weight: .medium), onAction: CompletionHandler = nil, onDismiss: CompletionHandler = nil) {
            self.message = message
            self.messageFont = messageFont
            self.duration = duration.asTimeInterval
            self.actionTitle = actionTitle
            self.actionFont = actionFont
            self.onAction = onAction
            self.onDismiss = onDismiss
        }
    }

    /// Shows a snackbar with the given view model.
    /// - Parameter viewModel: The data to display.
    public static func show(_ viewModel: ViewModel) {
        dispatchOnMain {
            let existingSnackbar = UIApplication.shared.topMostView?.subviews.first { $0 is SnackbarView } as? SnackbarView
            existingSnackbar?.dismiss()
            let snackbar = SnackbarView(viewModel: viewModel)
            snackbar.present()
        }
    }
}
