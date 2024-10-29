//
//  UIViewController+AnimateConstraintChanges.swift
//

import UIKit

// MARK: - Animate constraint changes
extension UIViewController {
    public func animate(_ options: UIView.AnimationOptions = [.curveEaseIn], constraintChanges: () -> Void, completion: CompletionHandler = nil) {
        constraintChanges()
        UIView.animate(
            withDuration: .DefaultValues.animationDuration,
            delay: .zero,
            options: options,
            animations: { self.view.layoutIfNeeded() },
            completion: { _ in completion?() }
        )
    }
}
