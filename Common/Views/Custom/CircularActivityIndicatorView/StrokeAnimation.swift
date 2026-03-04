//
//  StrokeAnimation.swift
//

import UIKit

/// A specialized `CABasicAnimation` for stroke animations (start or end).
final class StrokeAnimation: CABasicAnimation {
    
    /// Defines the type of stroke animation.
    enum StrokeType {
        /// Animation for `strokeStart`.
        case start
        /// Animation for `strokeEnd`.
        case end
    }

    override init() {
        super.init()
    }

    /// Initializes a new stroke animation.
    /// - Parameters:
    ///   - type: The type of stroke animation (start or end).
    ///   - beginTime: The delay before the animation begins. Defaults to 0/
    ///   - fromValue: The starting value of the stroke property.
    ///   - toValue: The ending value of the stroke property.
    ///   - duration: The duration of the animation.
    init(
        type: StrokeType,
        beginTime: Double = .zero,
        fromValue: CGFloat,
        toValue: CGFloat,
        duration: Double
    ) {
        super.init()
        self.keyPath = type == .start ? "strokeStart" : "strokeEnd"
        self.beginTime = beginTime
        self.fromValue = fromValue
        self.toValue = toValue
        self.duration = duration
        self.timingFunction = .init(name: .easeInEaseOut)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
