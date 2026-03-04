//
//  AVCaptureVideoPreviewLayer+VideoGravity.swift
//

import AVFoundation

extension AVCaptureVideoPreviewLayer {
    
    /// Sets the video gravity (how the video is displayed within the layer bounds) and returns self (chainable).
    /// - Parameter videoGravity: The video gravity to set.
    @discardableResult public func videoGravity(_ videoGravity: AVLayerVideoGravity) -> Self {
        with { $0.videoGravity = videoGravity }
    }
}
