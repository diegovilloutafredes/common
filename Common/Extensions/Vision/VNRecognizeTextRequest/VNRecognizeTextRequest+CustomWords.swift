//
//  VNRecognizeTextRequest+CustomWords.swift
//

import Vision

extension VNRecognizeTextRequest {
    @discardableResult public func customWords(_ customWords: [String]) -> Self {
        with { $0.customWords = customWords }
    }
}
