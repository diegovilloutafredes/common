//
//  AVCaptureDevice+FocusMode.swift
//

import AVFoundation

extension AVCaptureDevice {
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
