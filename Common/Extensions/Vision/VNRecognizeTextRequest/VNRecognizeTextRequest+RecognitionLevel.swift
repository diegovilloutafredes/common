//
//  VNRecognizeTextRequest+RecognitionLevel.swift
//

import Vision

extension VNRecognizeTextRequest {
    @discardableResult public func recognitionLevel(_ recognitionLevel: VNRequestTextRecognitionLevel) -> Self {
        with { $0.recognitionLevel = recognitionLevel }
    }
}
