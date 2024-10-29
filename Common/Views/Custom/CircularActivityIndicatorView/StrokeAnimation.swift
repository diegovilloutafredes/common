//
//  StrokeAnimation.swift
//

import UIKit

final class StrokeAnimation: CABasicAnimation {
    enum StrokeType {
        case start
        case end
    }

    override init() {
        super.init()
    }

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
