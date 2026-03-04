//
//  CMSampleBuffer+Width.swift
//

import CoreMedia

extension CMSampleBuffer {
    
    /// Returns the width of the pixel buffer contained in the sample buffer.
    public var width: Double? { asCVPixelBuffer?.width }
}
