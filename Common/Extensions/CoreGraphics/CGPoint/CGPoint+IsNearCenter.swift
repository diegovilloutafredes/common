//
//  CGPoint+IsNearCenter.swift
//

import CoreGraphics

extension CGPoint {
    
    /// Checks if the point is near the center of a given rectangle within a tolerance.
    /// - Parameters:
    ///   - rect: The rectangle to check against.
    ///   - tolerance: The tolerance percentage (0.0 to 1.0) of the rectangle's smallest dimension. Defaults to 0.1.
    /// - Returns: `true` if the point is within range of the center.
    public func isNearCenter(of rect: CGRect, tolerance: Double = 0.1) -> Bool {
        let distance = distance(to: rect.center)
        let minValue = min(rect.width, rect.height)
        let upperLimit = Double(minValue)*tolerance
        return (.zero..<upperLimit).contains(distance)
    }
}
