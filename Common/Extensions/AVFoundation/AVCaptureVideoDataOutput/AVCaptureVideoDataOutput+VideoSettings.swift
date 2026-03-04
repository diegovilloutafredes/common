//
//  AVCaptureVideoDataOutput+VideoSettings.swift
//

import AVFoundation

extension AVCaptureVideoDataOutput {
    
    /// Sets the video settings and returns self (chainable).
    /// - Parameter videoSettings: The dictionary of video settings.
    @discardableResult public func videoSettings(_ videoSettings: [String: Any]) -> Self {
        with { $0.videoSettings = videoSettings }
    }
}
