//
//  AVCaptureVideoPreviewLayer+VideoGravity.swift
//

import AVFoundation

extension AVCaptureVideoPreviewLayer {
    @discardableResult public func videoGravity(_ videoGravity: AVLayerVideoGravity) -> Self {
        with { $0.videoGravity = videoGravity }
    }
}
