//
//  RotationAnimation.swift
//

import UIKit

/// A specialized `CABasicAnimation` for rotation.
final class RotationAnimation: CABasicAnimation {
    override init() {
        super.init()
    }

    /// Initializes a new rotation animation.
    /// - Parameters:
    ///   - fromValue: The starting rotation value in radians.
    ///   - toValue: The ending rotation value in radians.
    ///   - duration: The duration of the animation.
    ///   - repeatCount: The number of times to repeat the animation.
    init(
        fromValue: CGFloat,
        toValue: CGFloat,
        duration: Double,
        repeatCount: Float
    ) {
        super.init()
        self.keyPath = "transform.rotation"
        self.fromValue = fromValue
        self.toValue = toValue
        self.duration = duration
        self.repeatCount = repeatCount
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
