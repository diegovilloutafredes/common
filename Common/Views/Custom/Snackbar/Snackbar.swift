//
//  Snackbar.swift
//

import UIKit

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

    /// The window that hosts snackbars. Injectable seam: the hostless unit-test
    /// bundle has no foreground-active scene, so UIApplication discovery
    /// returns nil there.
    @MainActor static var hostWindow: () -> UIWindow? = { UIApplication.shared.keyWindow }

    /// The snackbar currently on screen, if any — at most one is visible at a time.
    /// Tracked directly (weak) rather than searched for: the snackbar lives on the
    /// key window, so a `topMostView` subview search never finds it.
    @MainActor private(set) static weak var current: SnackbarView?

    /// Shows a snackbar with the given view model, dismissing any snackbar
    /// already on screen first.
    /// - Parameter viewModel: The data to display.
    public static func show(_ viewModel: ViewModel) {
        dispatchOnMain {
            // dispatchOnMain guarantees main-thread execution; assert that to
            // the type system for the MainActor-isolated state below.
            MainActor.assumeIsolated {
                current?.dismiss()
                let snackbar = SnackbarView(viewModel: viewModel)
                current = snackbar
                snackbar.present()
            }
        }
    }
}
