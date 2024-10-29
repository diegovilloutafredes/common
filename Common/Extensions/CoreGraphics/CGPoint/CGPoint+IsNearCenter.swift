//
//  CGPoint+IsNearCenter.swift
//

import CoreGraphics

extension CGPoint {
    public func isNearCenter(of rect: CGRect, tolerance: Double = 0.1) -> Bool {
        let distance = distance(to: rect.center)
        let minValue = min(rect.width, rect.height)
        let upperLimit = Double(minValue)*tolerance
        return (.zero..<upperLimit).contains(distance)
    }
}
