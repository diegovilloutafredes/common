//
//  AVCaptureVideoPreviewLayer+Session.swift
//

import AVFoundation

extension AVCaptureVideoPreviewLayer {
    @discardableResult public func session(_ session: AVCaptureSession?) -> Self {
        with { $0.session = session }
    }
}
