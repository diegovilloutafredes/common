//
//  AVCaptureVideoPreviewLayer+VideoOrientation.swift
//

import AVFoundation

extension AVCaptureVideoPreviewLayer {
    @discardableResult public func videoOrientation(_ videoOrientation: AVCaptureVideoOrientation) -> Self {
        with { $0.connection?.videoOrientation = videoOrientation }
    }
}
