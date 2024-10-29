//
//  CVPixelBuffer+Height.swift
//

import Accelerate

extension CVPixelBuffer {
    public var height: Double { .init(CVPixelBufferGetHeight(self)) }
}
