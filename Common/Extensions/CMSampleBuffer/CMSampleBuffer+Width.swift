//
//  CMSampleBuffer+Width.swift
//

import CoreMedia

extension CMSampleBuffer {
    public var width: Double? { asCVPixelBuffer?.width }
}
