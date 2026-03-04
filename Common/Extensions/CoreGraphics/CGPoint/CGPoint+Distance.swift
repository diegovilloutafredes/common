//
//  CGPoint+Distance.swift
//

import CoreGraphics

extension CGPoint {
    
    /// Calculates the distance to another point.
    /// - Parameter to: The destination point.
    /// - Returns: The Euclidean distance between the two points.
    public func distance(to: CGPoint) -> CGFloat {
        sqrt((x - to.x) * (x - to.x) + (y - to.y) * (y - to.y))
    }
}
