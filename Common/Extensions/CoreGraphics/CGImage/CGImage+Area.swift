//
//  CGImage+Area.swift
//

import CoreGraphics

extension CGImage {
    public var area: Double { .init(width * height) }
}
