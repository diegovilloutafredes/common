//
//  CGRect+Init.swift
//

import CoreGraphics

extension CGRect {
    init(width: Double, height: Double) {
        self.init(x: .zero, y: .zero, width: width, height: height)
    }
}

extension CGRect {
    init(width: Int, height: Int) {
        self.init(x: .zero, y: .zero, width: width, height: height)
    }
}
