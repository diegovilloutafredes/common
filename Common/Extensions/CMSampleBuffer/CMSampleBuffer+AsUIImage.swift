//
//  CMSampleBuffer+AsUIImage.swift
//

import CoreMedia
import UIKit

extension CMSampleBuffer {
    
    /// Converts the sample buffer to a UIImage, if possible.
    public var asUIImage: UIImage? { asCGImage.isNotNil ? .init(cgImage: asCGImage!) : nil }
}
