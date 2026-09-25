//
//  AVCaptureDevice+ToggleTorch.swift
//

import AVFoundation

extension AVCaptureDevice {
    
    /// Toggles the torch on or off and returns self (chainable). Nothing changes when the device
    /// doesn't support the target mode: AVFoundation raises an exception Swift can't catch.
    @discardableResult public func toggleTorch() -> Self {
        with {
            do {
                try lockForConfiguration()
                let target: TorchMode = $0.torchMode == .on ? .off : .on
                if
                    $0.hasTorch,
                    $0.isTorchAvailable,
                    $0.isTorchModeSupported(target) {
                    $0.torchMode = target
                }
                unlockForConfiguration()
            } catch {}
        }
    }
}
