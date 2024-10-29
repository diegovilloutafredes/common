//
//  CMSampleBuffer+AsUIImage.swift
//

import CoreMedia
import UIKit

extension CMSampleBuffer {
    public var asUIImage: UIImage? { asCGImage.isNotNil ? .init(cgImage: asCGImage!) : nil }
}
