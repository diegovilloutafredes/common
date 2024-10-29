//
//  AVCaptureDevice+.swift
//

import AVFoundation

extension AVCaptureDevice {
    @discardableResult public func autoFocusRangeRestriction(_ autoFocusRangeRestriction: AutoFocusRangeRestriction) -> Self {
        with {
            do {
                try lockForConfiguration()
                $0.autoFocusRangeRestriction = autoFocusRangeRestriction
                unlockForConfiguration()
            } catch {}
        }
    }
}
