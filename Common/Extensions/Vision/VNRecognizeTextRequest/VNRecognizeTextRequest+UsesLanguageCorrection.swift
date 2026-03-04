//
//  VNRecognizeTextRequest+UsesLanguageCorrection.swift
//

import Vision

extension VNRecognizeTextRequest {
    
    /// Sets whether to use language correction and returns self (chainable).
    /// - Parameter usesLanguageCorrection: `true` to use language correction.
    @discardableResult public func usesLanguageCorrection(_ usesLanguageCorrection: Bool) -> Self {
        with { $0.usesLanguageCorrection = usesLanguageCorrection }
    }
}
