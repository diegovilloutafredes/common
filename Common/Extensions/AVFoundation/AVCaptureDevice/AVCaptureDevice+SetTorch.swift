//
//  AVCaptureDevice+SetTorch.swift
//

import AVFoundation

extension AVCaptureDevice {
    
    /// Sets the torch level and returns self (chainable). A level of zero or less turns the torch
    /// off, and a level above 1.0 is capped at 1.0. Nothing changes when the device has no available
    /// torch or doesn't support the needed mode: AVFoundation raises an exception Swift can't catch.
    /// - Parameter level: The brightness level between 0.0 and 1.0.
    @discardableResult public func setTorch(level: Double) -> Self {
        with {
            do {
                try lockForConfiguration()
                if
                    $0.hasTorch,
                    $0.isTorchAvailable {
                    if let level = Self.normalizedTorchLevel(level) {
                        if $0.isTorchModeSupported(.on) { try? $0.setTorchModeOn(level: level) }
                    } else if $0.isTorchModeSupported(.off) {
                        $0.torchMode = .off
                    }
                }
                unlockForConfiguration()
            } catch {
                Logger.log(["lockForConfiguration error": error])
            }
        }
    }

    /// The level `setTorchModeOn(level:)` accepts for a requested `level`, capped at 1.0; nil (turn
    /// the torch off) for zero, less, or NaN, which that method raises on.
    static func normalizedTorchLevel(_ level: Double) -> Float? {
        guard level > 0 else { return nil }
        return Float(Swift.min(level, 1))
    }
}
