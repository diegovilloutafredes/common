//
//  CMSampleBuffer+Size.swift
//

import CoreMedia

extension CMSampleBuffer {
    
    /// Returns the size of the pixel buffer contained in the sample buffer.
    public var size: CGSize? { asCVPixelBuffer?.size }
}
