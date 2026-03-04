//
//  VNRecognizeTextRequest+RecognitionLevel.swift
//

import Vision

extension VNRecognizeTextRequest {
    
    /// Sets the recognition level (accurate or fast) and returns self (chainable).
    /// - Parameter recognitionLevel: The level of recognition.
    @discardableResult public func recognitionLevel(_ recognitionLevel: VNRequestTextRecognitionLevel) -> Self {
        with { $0.recognitionLevel = recognitionLevel }
    }
}
