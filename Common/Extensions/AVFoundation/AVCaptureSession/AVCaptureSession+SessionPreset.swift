//
//  AVCaptureSession+SessionPreset.swift
//

import AVFoundation

extension AVCaptureSession {
    
    /// Sets the session preset and returns self (chainable).
    /// - Parameter sessionPreset: The preset to use.
    @discardableResult public func sessionPreset(_ sessionPreset: Preset) -> Self {
        with { $0.sessionPreset = sessionPreset }
    }
}
