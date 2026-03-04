//
//  AVCaptureDevice+AutoFocusRangeRestriction.swift
//

import AVFoundation

extension AVCaptureDevice {
    
    /// Sets the auto-focus range restriction and returns self (chainable).
    /// - Parameter autoFocusRangeRestriction: The range restriction to set.
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
