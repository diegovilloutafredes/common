//
//  AVCaptureVideoPreviewLayer+VideoOrientation.swift
//

import AVFoundation

extension AVCaptureVideoPreviewLayer {
    
    /// Sets the video orientation for the preview layer's connection and returns self (chainable).
    /// - Parameter videoOrientation: The orientation to set.
    @available(iOS, deprecated: 17.0, message: "Set videoRotationAngle on the connection, with an angle from AVCaptureDevice.RotationCoordinator.")
    @discardableResult public func videoOrientation(_ videoOrientation: AVCaptureVideoOrientation) -> Self {
        with { $0.connection?.videoOrientation = videoOrientation }
    }
}
