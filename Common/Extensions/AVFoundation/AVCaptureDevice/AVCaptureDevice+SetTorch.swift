//
//  AVCaptureDevice+SetTorch.swift
//

import AVFoundation

extension AVCaptureDevice {
    
    /// Sets the torch level and returns self (chainable).
    /// - Parameter level: The level between 0.0 and 1.0. Defaults to 0.7 if successful.
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
