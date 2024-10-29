//
//  CMSampleBuffer+AsCVPixelBuffer.swift
//

import CoreMedia

extension CMSampleBuffer {
    public var asCVPixelBuffer: CVPixelBuffer? { CMSampleBufferGetImageBuffer(self) }
}
