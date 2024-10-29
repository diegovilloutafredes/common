//
//  CVPixelBuffer+Size.swift
//

import Accelerate

extension CVPixelBuffer {
    public var size: CGSize { .init(width: width, height: height) }
}
