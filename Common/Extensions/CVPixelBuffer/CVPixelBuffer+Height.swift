//
//  CVPixelBuffer+Height.swift
//

import Accelerate

extension CVPixelBuffer {
    
    /// Returns the height of the pixel buffer.
    public var height: Double { .init(CVPixelBufferGetHeight(self)) }
}
