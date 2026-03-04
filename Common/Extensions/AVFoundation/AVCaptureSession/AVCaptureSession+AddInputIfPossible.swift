//
//  AVCaptureSession+AddInputIfPossible.swift
//

import AVFoundation

extension AVCaptureSession {
    
    /// Adds an input to the session if possible and returns self (chainable).
    /// - Parameter input: The input to add.
    @discardableResult public func addInputIfPossible(_ input: AVCaptureDeviceInput) -> Self {
        with {
            guard $0.canAddInput(input) else { return }
            $0.addInput(input)
        }
    }
}
