//
//  AVCaptureSession+AddOutputIfPossible.swift
//

import AVFoundation

extension AVCaptureSession {
    @discardableResult public func addOutputIfPossible(_ output: AVCaptureVideoDataOutput) -> Self {
        with {
            guard $0.canAddOutput(output) else { return }
            $0.addOutput(output)
        }
    }
}
