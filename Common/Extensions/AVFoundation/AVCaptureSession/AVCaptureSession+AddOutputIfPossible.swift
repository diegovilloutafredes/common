//
//  AVCaptureSession+AddOutputIfPossible.swift
//

import AVFoundation

extension AVCaptureSession {
    
    /// Adds an output to the session if possible and returns self (chainable).
    /// - Parameter output: The output to add.
    @discardableResult public func addOutputIfPossible(_ output: AVCaptureVideoDataOutput) -> Self {
        with {
            guard $0.canAddOutput(output) else { return }
            $0.addOutput(output)
        }
    }
}
