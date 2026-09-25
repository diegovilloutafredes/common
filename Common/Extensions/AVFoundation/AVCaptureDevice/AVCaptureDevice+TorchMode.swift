//
//  AVCaptureDevice+TorchMode.swift
//

import AVFoundation

extension AVCaptureDevice {
    
    /// Sets the torch mode and returns self (chainable). Nothing changes when the device doesn't
    /// support the mode: AVFoundation raises an exception Swift can't catch.
    /// - Parameter torchMode: The torch mode to set.
    @discardableResult public func torchMode(_ torchMode: TorchMode) -> Self {
        with {
            do {
                try lockForConfiguration()
                if
                    $0.hasTorch,
                    $0.isTorchAvailable,
                    $0.isTorchModeSupported(torchMode) {
                    $0.torchMode = torchMode
                }
                unlockForConfiguration()
            } catch {}
        }
    }
}
