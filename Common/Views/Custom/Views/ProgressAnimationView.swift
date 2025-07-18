//
//  ProgressAnimationView.swift
//

import UIKit

public final class ProgressAnimationView: UIView {
    private var completion: CompletionHandler = nil

    public func animate(progressColor: CGColor, backgroundColor: CGColor, duration: CFTimeInterval, completion: CompletionHandler) {
        self.completion = completion

        let layer = CAGradientLayer()
        let startLocations = [0, 0]
        let endLocations = [1, 1]

        layer.colors = [progressColor, backgroundColor]
        layer.frame = frame
        layer.locations = startLocations as [NSNumber]
        layer.startPoint = .init(x: 0.0, y: 1.0)
        layer.endPoint = .init(x: 1.0, y: 1.0)

        layer.cornerRadius = 8

        self.layer.addSublayer(layer)

        let animation = CABasicAnimation(keyPath: "locations")
        animation.delegate = self
        animation.duration = duration
        animation.fromValue = startLocations
        animation.toValue = endLocations

        layer.locations = endLocations as [NSNumber]
        layer.add(animation, forKey: "loc")
    }
}

// MARK: - CAAnimationDelegate
extension ProgressAnimationView: CAAnimationDelegate {
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard flag else { completion = nil; return }
        completion?()
    }
}
