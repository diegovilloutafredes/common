//
//  UIViewController+AnimateConstraintChanges.swift
//

import UIKit

// MARK: - Animate constraint changes
extension UIViewController {
    
    /// Animates constraint changes with layoutIfNeeded.
    /// - Parameters:
    ///   - duration: The animation duration.
    ///   - options: The animation options.
    ///   - constraintChanges: Block to perform constraint changes.
    ///   - completion: Completion handler.
    public func animateConstraints(_ duration: TimeInterval = .DefaultValues.animationDuration, options: UIView.AnimationOptions = .curveEaseInOut, constraintChanges: @escaping Action, completion: Handler<Bool>? = nil) {
        if Thread.isMainThread {
            constraintChanges()
            UIView.animate(
                withDuration: duration,
                delay: .zero,
                options: options,
                animations: { [weak self] in guard let self else { return }; view.layoutIfNeeded() },
                completion: completion
            )
        } else { dispatchOnMain { [weak self] in guard let self else { return }; animateConstraints(duration, options: options, constraintChanges: constraintChanges, completion: completion) } }
    }
}
