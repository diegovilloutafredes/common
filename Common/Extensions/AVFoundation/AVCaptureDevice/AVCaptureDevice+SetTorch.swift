//
//  AVCaptureDevice+SetTorch.swift
//

import AVFoundation

extension AVCaptureDevice {
    
    /// Sets the torch level and returns self (chainable).
    /// - Parameter level: The brightness level between 0.0 and 1.0.
    @discardableResult public func setTorch(level: Double) -> Self {
        with {
            do {
                try lockForConfiguration()
                if
                    $0.hasTorch,
                    $0.isTorchAvailable {
                    try? $0.setTorchModeOn(level: Float(level))
                }
                unlockForConfiguration()
            } catch {
                Logger.log(["lockForConfiguration error": error])
            }
        }
    }
}
