//
//  CMSampleBuffer+Size.swift
//

import CoreMedia

extension CMSampleBuffer {
    public var size: CGSize? { asCVPixelBuffer?.size }
}
