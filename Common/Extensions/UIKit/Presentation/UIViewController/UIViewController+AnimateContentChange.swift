//
//  UIViewController+AnimateContentChange.swift
//

import UIKit

// MARK: - Animate content change
extension UIViewController {

    /// Animates the update pass that a change to observed state causes: `updateContent()` and the layout that applies
    /// what it wrote, such as a constraint constant the hook sets from a view model flag.
    ///
    /// ```swift
    /// animateContentChange { [weak self] in self?.viewModel.toggleDetails() }
    /// ```
    ///
    /// One call for both observation modes, with no branch on the OS version:
    /// - On iOS 26 (the native mode) it runs `changes` as the animations, with `.flushUpdates` added to `options`, so
    ///   UIKit runs the update pass the change invalidated, and the layout after it, inside the animation.
    /// - On iOS 17–18 (the manual mode) it runs `changes`, whose write on the main thread schedules the pass, and then
    ///   the view's `layoutIfNeeded()` inside the animation, which runs `updateContent()` and the layout, as
    ///   `animateConstraints` does. It lays out the controller's view only, so a change that moves views outside it
    ///   doesn't animate.
    ///
    /// A write of a value equal to the current one schedules no pass: nothing animates, and `completion` still runs.
    /// Called off the main thread, it does the same work on the main thread.
    /// - Parameters:
    ///   - duration: The animation duration.
    ///   - options: The animation options.
    ///   - changes: Writes the observed state the controller's hook reads.
    ///   - completion: Called once when the animation ends, with whether it finished.
    public func animateContentChange(_ duration: TimeInterval = .DefaultValues.animationDuration, options: UIView.AnimationOptions = .curveEaseInOut, changes: @escaping Action, completion: Handler<Bool>? = nil) {
        guard Thread.isMainThread else {
            dispatchOnMain { [weak self] in
                guard let self else { return }
                animateContentChange(duration, options: options, changes: changes, completion: completion)
            }
            return
        }
        if #available(iOS 26.0, *), ObservationMode.current == .native {
            UIView.animate(withDuration: duration, delay: .zero, options: options.union(.flushUpdates), animations: changes, completion: completion)
            return
        }
        changes()
        UIView.animate(
            withDuration: duration,
            delay: .zero,
            options: options,
            animations: { [weak self] in guard let self else { return }; view.layoutIfNeeded() },
            completion: completion
        )
    }
}
