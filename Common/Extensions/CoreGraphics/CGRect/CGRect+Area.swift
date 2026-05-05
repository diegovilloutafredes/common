//
//  CGRect+Area.swift
//

import CoreGraphics

extension CGRect {
    
    /// Calculated area of the rectangle (width * height).
    public var area: Double { width * height }
}
