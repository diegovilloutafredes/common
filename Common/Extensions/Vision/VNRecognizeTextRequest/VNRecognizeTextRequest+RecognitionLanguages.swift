//
//  VNRecognizeTextRequest+RecognitionLanguages.swift
//

import Vision

extension VNRecognizeTextRequest {
    
    /// Sets the recognition languages and returns self (chainable).
    /// - Parameter recognitionLanguages: The languages to use for recognition.
    @discardableResult public func recognitionLanguages(_ recognitionLanguages: [String]) -> Self {
        with { $0.recognitionLanguages = recognitionLanguages }
    }
}
