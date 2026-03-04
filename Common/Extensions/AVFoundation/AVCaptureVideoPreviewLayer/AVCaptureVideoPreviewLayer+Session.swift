//
//  AVCaptureVideoPreviewLayer+Session.swift
//

import AVFoundation

extension AVCaptureVideoPreviewLayer {
    
    /// Sets the session for the preview layer and returns self (chainable).
    /// - Parameter session: The capture session to attach.
    @discardableResult public func session(_ session: AVCaptureSession?) -> Self {
        with { $0.session = session }
    }
}
