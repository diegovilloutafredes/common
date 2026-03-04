//
//  AVCaptureDevice+FocusMode.swift
//

import AVFoundation

extension AVCaptureDevice {
    
    /// Sets the focus mode if supported and returns self (chainable).
    /// - Parameter focusMode: The focus mode to set.
    @discardableResult public func focusModeIfPossible(_ focusMode: FocusMode) -> Self {
        with {
            do {
                try $0.lockForConfiguration()
                if $0.isFocusModeSupported(focusMode) { $0.focusMode = focusMode }
                $0.unlockForConfiguration()
            } catch {}
        }
    }
}
