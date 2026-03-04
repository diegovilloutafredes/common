//
//  AVCaptureDevice+TorchMode.swift
//

import AVFoundation

extension AVCaptureDevice {
    
    /// Sets the torch mode and returns self (chainable).
    /// - Parameter torchMode: The torch mode to set.
    @discardableResult public func torchMode(_ torchMode: TorchMode) -> Self {
        with {
            do {
                try lockForConfiguration()
                if
                    $0.hasTorch,
                    $0.isTorchAvailable {
                    $0.torchMode = torchMode
                }
                unlockForConfiguration()
            } catch {}
        }
    }
}
