//
//  CGRect+Init.swift
//

import CoreGraphics

extension CGRect {
    
    /// Initializes a rectangle with origin (0,0) and specified dimensions.
    /// - Parameters:
    ///   - width: The width.
    ///   - height: The height.
    init(width: Double, height: Double) {
        self.init(x: .zero, y: .zero, width: width, height: height)
    }
}

extension CGRect {
    
    /// Initializes a rectangle with origin (0,0) and specified integer dimensions.
    /// - Parameters:
    ///   - width: The integer width.
    ///   - height: The integer height.
    init(width: Int, height: Int) {
        self.init(x: .zero, y: .zero, width: width, height: height)
    }
}
