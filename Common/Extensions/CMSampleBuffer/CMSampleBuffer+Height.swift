//
//  CMSampleBuffer+Height.swift
//

import CoreMedia

extension CMSampleBuffer {
    
    /// Returns the height of the pixel buffer contained in the sample buffer.
    public var height: Double? { asCVPixelBuffer?.height }
}
