//
//  VNRecognizedTextObservation+TopRecognizedText.swift
//

import Vision

extension VNRecognizedTextObservation {
    
    /// Returns the top candidate for recognized text.
    public var topRecognizedText: VNRecognizedText? { topCandidates(1).first }
}
