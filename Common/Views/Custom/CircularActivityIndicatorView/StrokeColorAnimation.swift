//
//  StrokeColorAnimation.swift
//

import UIKit

final class StrokeColorAnimation: CAKeyframeAnimation {
    override init() {
        super.init()
    }

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
