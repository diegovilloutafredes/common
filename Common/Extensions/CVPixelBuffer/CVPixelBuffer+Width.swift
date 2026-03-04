//
//  CVPixelBuffer+Width.swift
//

import Accelerate

extension CVPixelBuffer {
    
    /// Returns the width of the pixel buffer.
    public var width: Double { .init(CVPixelBufferGetWidth(self)) }
}
