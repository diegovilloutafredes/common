//
//  CGRect+Center.swift
//

import CoreGraphics

extension CGRect {
    public var center: CGPoint { .init(x: midX, y: midY) }
}
