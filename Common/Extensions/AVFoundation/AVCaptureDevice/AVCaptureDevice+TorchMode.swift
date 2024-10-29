//
//  AVCaptureDevice+TorchMode.swift
//

import AVFoundation

extension AVCaptureDevice {
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
