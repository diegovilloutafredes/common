//
//  UIViewController+AnimateConstraintChanges.swift
//

import UIKit

// MARK: - Animate constraint changes
extension UIViewController {
    public func animate(_ duration: TimeInterval = .DefaultValues.animationDuration, options: UIView.AnimationOptions = [.curveEaseIn], constraintChanges: () -> Void, completion: CompletionHandler = nil) {
        constraintChanges()
        UIView.animate(
            withDuration: duration,
            delay: .zero,
            options: options,
            animations: { self.view.layoutIfNeeded() },
            completion: { _ in completion?() }
        )
    }
}
