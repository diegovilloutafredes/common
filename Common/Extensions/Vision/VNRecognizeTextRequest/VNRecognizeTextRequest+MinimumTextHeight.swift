//
//  VNRecognizeTextRequest+MinimumTextHeight.swift
//

import Vision

extension VNRecognizeTextRequest {
    @discardableResult public func minimumTextHeight(_ minimumTextHeight: Float) -> Self {
        with { $0.minimumTextHeight = minimumTextHeight }
    }
}
