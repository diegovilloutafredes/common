//
//  AVCaptureDevice+SetTorch.swift
//

import AVFoundation

extension AVCaptureDevice {
    @discardableResult public func setTorch(level: Double) -> Self {
        with {
            do {
                try lockForConfiguration()
                if
                    $0.hasTorch,
                    $0.isTorchAvailable {
                    try? $0.setTorchModeOn(level: 0.7)
                }
                unlockForConfiguration()
            } catch {}
        }
    }
}
