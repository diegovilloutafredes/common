//
//  CGImage+Area.swift
//

import CoreGraphics

extension CGImage {
    
    /// Calculated area of the image (width * height).
    public var area: Double { .init(width * height) }
}
