//
//  AVCaptureDevice+ExposureMode.swift
//

import AVFoundation

extension AVCaptureDevice {
    
    /// Sets the exposure mode if supported and returns self (chainable).
    /// - Parameter exposureMode: The exposure mode to set.
    @discardableResult public func exposureModeIfPossible(_ exposureMode: ExposureMode) -> Self {
        with {
            do {
                try $0.lockForConfiguration()
                if $0.isExposureModeSupported(exposureMode) { $0.exposureMode = exposureMode }
                $0.unlockForConfiguration()
            } catch {}
        }
    }
}
