//
//  CGPoint+Distance.swift
//

import CoreGraphics

extension CGPoint {
    public func distance(to: CGPoint) -> CGFloat {
        sqrt((x - to.x) * (x - to.x) + (y - to.y) * (y - to.y))
    }
}
