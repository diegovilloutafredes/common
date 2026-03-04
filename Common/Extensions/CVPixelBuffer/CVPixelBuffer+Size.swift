//
//  CVPixelBuffer+Size.swift
//

import Accelerate

extension CVPixelBuffer {
    
    /// Returns the size of the pixel buffer.
    public var size: CGSize { .init(width: width, height: height) }
}
