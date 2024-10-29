//
//  AVCaptureVideoDataOutput+VideoOrientation.swift
//

import AVFoundation

extension AVCaptureVideoDataOutput {
    @discardableResult public func videoOrientation(_ videoOrientation: AVCaptureVideoOrientation) -> Self {
        with { $0.connection(with: .video)?.videoOrientation = videoOrientation }
    }
}
