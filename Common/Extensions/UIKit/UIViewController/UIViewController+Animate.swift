//
//  UIView+Animate.swift
//

import UIKit

extension UIViewController {
    public func animate(_ duration: TimeInterval = .DefaultValues.animationDuration, delay: TimeInterval = .zero, options: UIView.AnimationOptions = .curveEaseInOut, animations: @escaping Action, completion: Handler<Bool>? = nil) {
        if Thread.isMainThread { UIView.animate(withDuration: duration, delay: delay, options: options, animations: animations, completion: completion) }
        else { dispatchOnMain { [weak self] in guard let self else { return }; animate(duration, delay: delay, options: options, animations: animations, completion: completion) } }
    }
}
