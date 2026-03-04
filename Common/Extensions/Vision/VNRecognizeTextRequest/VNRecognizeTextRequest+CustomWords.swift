//
//  VNRecognizeTextRequest+CustomWords.swift
//

import Vision

extension VNRecognizeTextRequest {
    
    /// Sets the custom words for text recognition and returns self (chainable).
    /// - Parameter customWords: An array of custom words to use during recognition.
    @discardableResult public func customWords(_ customWords: [String]) -> Self {
        with { $0.customWords = customWords }
    }
}
