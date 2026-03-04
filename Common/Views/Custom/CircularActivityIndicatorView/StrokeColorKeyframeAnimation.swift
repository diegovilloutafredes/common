//
//  StrokeColorKeyframeAnimation.swift
//

import UIKit

/// A specialized `CAKeyframeAnimation` for animating stroke colors.
final class StrokeColorKeyframeAnimation: CAKeyframeAnimation {
    override init() {
        super.init()
    }

    /// Initializes a new stroke color keyframe animation.
    /// - Parameters:
    ///   - colors: An array of `CGColor` values to animate through.
    ///   - duration: The total duration of the animation cycle.
    init(colors: [CGColor], duration: Double) {
        super.init()
        self.keyPath = "strokeColor"
        self.values = colors
        self.duration = duration
        self.repeatCount = .infinity
        self.timingFunction = .init(name: .easeInEaseOut)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
