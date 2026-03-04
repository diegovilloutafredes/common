//
//  CMSampleBuffer+AsCVPixelBuffer.swift
//

import CoreMedia

extension CMSampleBuffer {
    
    /// Returns the CVPixelBuffer from the sample buffer, if available.
    public var asCVPixelBuffer: CVPixelBuffer? { CMSampleBufferGetImageBuffer(self) }
}
