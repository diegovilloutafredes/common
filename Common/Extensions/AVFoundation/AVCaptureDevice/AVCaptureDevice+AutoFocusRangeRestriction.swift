//
//  AVCaptureDevice+AutoFocusRangeRestriction.swift
//

import AVFoundation

extension AVCaptureDevice {
    
    /// Sets the auto-focus range restriction and returns self (chainable). Nothing changes on a
    /// device that doesn't support range restrictions: AVFoundation raises an exception Swift can't catch.
    /// - Parameter autoFocusRangeRestriction: The range restriction to set.
    @discardableResult public func autoFocusRangeRestriction(_ autoFocusRangeRestriction: AutoFocusRangeRestriction) -> Self {
        with {
            do {
                try lockForConfiguration()
                if $0.isAutoFocusRangeRestrictionSupported { $0.autoFocusRangeRestriction = autoFocusRangeRestriction }
                unlockForConfiguration()
            } catch {}
        }
    }
}
