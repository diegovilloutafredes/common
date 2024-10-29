//
//  AVCaptureSession+AddInputIfPossible.swift
//

import AVFoundation

extension AVCaptureSession {
    @discardableResult public func addInputIfPossible(_ input: AVCaptureDeviceInput) -> Self {
        with {
            guard $0.canAddInput(input) else { return }
            $0.addInput(input)
        }
    }
}
