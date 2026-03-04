//
//  AVCaptureVideoPreviewLayer+VideoOrientation.swift
//

import AVFoundation

extension AVCaptureVideoPreviewLayer {
    
    /// Sets the video orientation for the preview layer's connection and returns self (chainable).
    /// - Parameter videoOrientation: The orientation to set.
    @discardableResult public func videoOrientation(_ videoOrientation: AVCaptureVideoOrientation) -> Self {
        with { $0.connection?.videoOrientation = videoOrientation }
    }
}
