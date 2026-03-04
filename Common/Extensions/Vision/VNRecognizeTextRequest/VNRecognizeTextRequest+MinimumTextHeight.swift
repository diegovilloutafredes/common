//
//  VNRecognizeTextRequest+MinimumTextHeight.swift
//

import Vision

extension VNRecognizeTextRequest {
    
    /// Sets the minimum text height regarding the image height (0.0 to 1.0) and returns self (chainable).
    /// - Parameter minimumTextHeight: The minimum height.
    @discardableResult public func minimumTextHeight(_ minimumTextHeight: Float) -> Self {
        with { $0.minimumTextHeight = minimumTextHeight }
    }
}
