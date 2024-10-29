//
//  CMSampleBuffer+Height.swift
//

import CoreMedia

extension CMSampleBuffer {
    public var height: Double? { asCVPixelBuffer?.height }
}
