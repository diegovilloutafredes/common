//
//  Toast.swift
//

import UIKit

// MARK: - Toast
// MARK: - Toast

/// A utility for presenting toast messages.
public enum Toast {
    
    /// Defines the duration of the toast presentation.
    public enum Duration: Int {
        case short = 1
        case medium = 3
        case long = 5

        var asTimeInterval: TimeInterval { .init(self.rawValue) }
    }

    /// Presents a toast message.
    /// - Parameters:
    ///   - message: The message to display.
    ///   - duration: The duration of the toast. Defaults to `.medium`.
    ///   - completion: A closure called after the toast has been dismissed.
    public static func present(with message: String, duration: Duration = .medium, completion: CompletionHandler = nil) {
        dispatchOnMain {
            guard let view = UIApplication.shared.topMostView else { return }

            let label = PillUILabel(message)
                .alpha(.zero)

            let stackView = VStack(
                alignment: .center,
                margins: .DefaultValues.StackView.margins
            ) { label }
                .setConstraints { $0.snapLeadBottomTrail(to: $1.safeAreaLayoutGuide) }

            view.subviews { stackView }

            UIView.animate(
                withDuration: 1,
                animations: { label.alpha(1) },
                completion: { _ in
                    dispatchOnMainAfter(.now() + duration.asTimeInterval) {
                        UIView.animate(
                            withDuration: 1,
                            animations: { label.alpha(.zero) },
                            completion: { _ in
                                stackView.removeFromSuperview()
                                completion?()
                            }
                        )
                    }
                }
            )
        }
    }
}
