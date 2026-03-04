//
//  AVCaptureVideoDataOutput+VideoOrientation.swift
//

import AVFoundation

extension AVCaptureVideoDataOutput {
    
    /// Sets the video orientation for the connection and returns self (chainable).
    /// - Parameter videoOrientation: The orientation to set.
    @discardableResult public func videoOrientation(_ videoOrientation: AVCaptureVideoOrientation) -> Self {
        with { $0.connection(with: .video)?.videoOrientation = videoOrientation }
    }
}
