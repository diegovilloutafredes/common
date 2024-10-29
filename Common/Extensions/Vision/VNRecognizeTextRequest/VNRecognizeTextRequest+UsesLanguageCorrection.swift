//
//  VNRecognizeTextRequest+UsesLanguageCorrection.swift
//

import Vision

extension VNRecognizeTextRequest {
    @discardableResult public func usesLanguageCorrection(_ usesLanguageCorrection: Bool) -> Self {
        with { $0.usesLanguageCorrection = usesLanguageCorrection }
    }
}
