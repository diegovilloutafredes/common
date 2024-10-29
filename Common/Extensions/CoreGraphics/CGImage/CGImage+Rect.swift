//
//  CGImage+Rect.swift
//

import CoreGraphics

extension CGImage {
    public var rect: CGRect { .init(width: width, height: height) }
}
