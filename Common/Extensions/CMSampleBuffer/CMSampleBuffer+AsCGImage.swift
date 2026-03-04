//
//  CMSampleBuffer+AsCGImage.swift
//

import CoreImage
import CoreMedia

extension CMSampleBuffer {
    
    /// Converts the sample buffer to a CGImage, if possible.
    public var asCGImage: CGImage? {
        guard let cvPixelBuffer = CMSampleBufferGetImageBuffer(self) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: cvPixelBuffer)
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return cgImage
    }
}
