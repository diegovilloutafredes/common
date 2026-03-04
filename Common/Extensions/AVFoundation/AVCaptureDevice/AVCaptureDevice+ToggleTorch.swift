//
//  AVCaptureDevice+ToggleTorch.swift
//

import AVFoundation

extension AVCaptureDevice {
    
    /// Toggles the torch on or off and returns self (chainable).
    @discardableResult public func toggleTorch() -> Self {
        with {
            do {
                try lockForConfiguration()
                if
                    $0.hasTorch,
                    $0.isTorchAvailable {
                    $0.torchMode = $0.torchMode == .on ? .off : .on
                }
                unlockForConfiguration()
            } catch {}
        }
    }
}
