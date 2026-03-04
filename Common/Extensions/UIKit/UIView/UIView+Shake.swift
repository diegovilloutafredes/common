//
//  UIView+Shake.swift
//

import UIKit

extension UIView {
    
    /// Plays a shake animation on the view.
    /// - Parameters:
    ///   - duration: The animation duration. Defaults to `0.3`.
    ///   - intensity: The maximum shake offset. Defaults to `15`.
    ///   - stepDecrement: The amount to reduce intensity each step. Defaults to `5`.
    ///   - completion: Completion handler.
    public func shake(_ duration: Double = 0.3, intensity: CGFloat = 15, stepDecrement: CGFloat = 5, completion: CompletionHandler = nil) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
            .with {
                $0.duration = duration
                $0.isRemovedOnCompletion = true
                $0.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                $0.values = shakeValues(maxValue: intensity, step: stepDecrement)
            }
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        layer.add(animation, forKey: "shake")
        CATransaction.commit()
    }

    private func shakeValues(maxValue: CGFloat, step: CGFloat) -> [CGFloat] {
        guard
            maxValue > .zero,
            step > .zero
        else { return [.zero] }

        var values = [CGFloat]()
        var current = maxValue

        values.append(-current)

        while current > .zero {
            values.append(current)
            current = max(.zero, current - step)

            guard current > .zero else { break }

            values.append(-current)
        }

        values.append(.zero)

        return values
    }
}
