//
//  VNRecognizeTextRequest+RecognitionLanguages.swift
//

import Vision

extension VNRecognizeTextRequest {
    @discardableResult public func recognitionLanguages(_ recognitionLanguages: [String]) -> Self {
        with { $0.recognitionLanguages = recognitionLanguages }
    }
}
