//
//  AVCaptureSession+SessionPreset.swift
//

import AVFoundation

extension AVCaptureSession {
    @discardableResult public func sessionPreset(_ sessionPreset: Preset) -> Self {
        with { $0.sessionPreset = sessionPreset }
    }
}
