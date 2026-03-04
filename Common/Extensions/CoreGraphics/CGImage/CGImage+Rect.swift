//
//  CGImage+Rect.swift
//

import CoreGraphics

extension CGImage {
    
    /// Returns a CGRect with the image's dimensions (at origin 0,0).
    public var rect: CGRect { .init(width: width, height: height) }
}
