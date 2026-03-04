//
//  UIView+Animate.swift
//

import UIKit

extension UIViewController {
    
    /// Performs a view animation on the main thread.
    /// - Parameters:
    ///   - duration: The animation duration.
    ///   - delay: The delay before animation starts.
    ///   - options: The animation options.
    ///   - animations: The animation block.
    ///   - completion: Completion handler.
    public func animate(_ duration: TimeInterval = .DefaultValues.animationDuration, delay: TimeInterval = .zero, options: UIView.AnimationOptions = .curveEaseInOut, animations: @escaping Action, completion: Handler<Bool>? = nil) {
        if Thread.isMainThread { UIView.animate(withDuration: duration, delay: delay, options: options, animations: animations, completion: completion) }
        else { dispatchOnMain { [weak self] in guard let self else { return }; animate(duration, delay: delay, options: options, animations: animations, completion: completion) } }
    }
}
