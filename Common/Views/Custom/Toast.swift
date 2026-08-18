//
//  Toast.swift
//

import UIKit

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

    /// The view that hosts toasts. Injectable seam: the hostless unit-test
    /// bundle has no foreground-active scene, so UIApplication discovery
    /// returns nil there.
    @MainActor static var hostView: () -> UIView? = { UIApplication.shared.topMostView }

    /// The toast currently on screen, if any — at most one is visible at a time.
    @MainActor private(set) static weak var current: UIView?

    /// Holds the current toast on screen for its duration. A `Task` (not a
    /// DispatchQueue timer) so async tests can await the completion without
    /// pumping `DispatchQueue.main` — see the Xcode 26 concurrency gotcha.
    @MainActor private static var holdTask: Task<Void, Never>?

    /// The current toast's completion — delivered exactly once, on whichever
    /// path ends the presentation (natural fade-out or replacement).
    @MainActor private static var currentCompletion: CompletionHandler = nil

    /// Presents a toast message, replacing any toast already on screen.
    ///
    /// The toast is purely informational: its whole hierarchy is
    /// touch-transparent and never blocks the UI beneath it. `completion` is
    /// always delivered exactly once — after the natural fade-out, at
    /// replacement time if a newer toast takes over, or immediately when no
    /// host view is available.
    /// - Parameters:
    ///   - message: The message to display.
    ///   - duration: The duration of the toast. Defaults to `.medium`.
    ///   - completion: A closure called after the toast has been dismissed.
    public static func present(with message: String, duration: Duration = .medium, completion: CompletionHandler = nil) {
        dispatchOnMain {
            // dispatchOnMain guarantees main-thread execution; assert that to
            // the type system for the MainActor-isolated state below.
            MainActor.assumeIsolated {
                dismissCurrent()

                guard let view = hostView() else { completion?(); return }

                let label = PillUILabel(message)
                    .alpha(.zero)

                let stackView = VStack(
                    alignment: .center,
                    margins: .DefaultValues.StackView.margins
                ) { label }
                    .isUserInteractionEnabled(false)
                    .setConstraints { $0.snapLeadBottomTrail(to: $1.safeAreaLayoutGuide) }

                view.subviews { stackView }
                current = stackView
                currentCompletion = completion

                UIView.animate(
                    withDuration: 1,
                    animations: { label.alpha(1) },
                    completion: { _ in
                        guard current === stackView else { return }
                        holdTask = Task { @MainActor in
                            try? await Task.sleep(nanoseconds: UInt64(duration.asTimeInterval * 1_000_000_000))
                            guard !Task.isCancelled, current === stackView else { return }
                            UIView.animate(
                                withDuration: 1,
                                animations: { label.alpha(.zero) },
                                completion: { _ in
                                    guard current === stackView else { return }
                                    dismissCurrent()
                                }
                            )
                        }
                    }
                )
            }
        }
    }

    /// Removes the toast currently on screen and delivers its completion.
    /// Clearing the tracking state first makes the call idempotent and lets the
    /// in-flight animation completions detect they have been superseded.
    @MainActor static func dismissCurrent() {
        holdTask?.cancel()
        holdTask = nil
        let dismissed = current
        current = nil
        let completion = currentCompletion
        currentCompletion = nil
        dismissed?.removeFromSuperview()
        completion?()
    }
}
