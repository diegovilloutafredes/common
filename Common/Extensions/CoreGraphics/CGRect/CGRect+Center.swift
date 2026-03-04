//
//  CGRect+Center.swift
//

import CoreGraphics

extension CGRect {
    
    /// Returns the center point of the rectangle.
    public var center: CGPoint { .init(x: midX, y: midY) }
}
