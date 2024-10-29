//
//  RotationAnimation.swift
//

import UIKit

final class RotationAnimation: CABasicAnimation {
    override init() {
        super.init()
    }

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
