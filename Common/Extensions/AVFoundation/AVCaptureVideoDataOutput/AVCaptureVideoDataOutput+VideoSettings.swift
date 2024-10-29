//
//  AVCaptureVideoDataOutput+VideoSettings.swift
//

import AVFoundation

extension AVCaptureVideoDataOutput {
    @discardableResult public func videoSettings(_ videoSettings: [String: Any]) -> Self {
        with { $0.videoSettings = videoSettings }
    }
}
