//
//  CVPixelBuffer+AsCMSampleBuffer.swift
//

import Accelerate
import CoreMedia

extension CVPixelBuffer {
    public var asCMSampleBuffer: CMSampleBuffer? {
        var sampleBuffer: CMSampleBuffer?
        var timimgInfo  = CMSampleTimingInfo()
        var formatDescription: CMFormatDescription? = nil

        CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: self, formatDescriptionOut: &formatDescription)

        CMSampleBufferCreateReadyWithImageBuffer(
          allocator: kCFAllocatorDefault,
          imageBuffer: self,
          formatDescription: formatDescription!,
          sampleTiming: &timimgInfo,
          sampleBufferOut: &sampleBuffer
        )

        return sampleBuffer
    }
}
