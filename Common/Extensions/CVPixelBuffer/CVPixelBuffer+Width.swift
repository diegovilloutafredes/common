//
//  CVPixelBuffer+Width.swift
//

import Accelerate

extension CVPixelBuffer {
    public var width: Double { .init(CVPixelBufferGetWidth(self)) }
}
