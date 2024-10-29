//
//  VNRecognizedTextObservation+TopRecognizedText.swift
//

import Vision

extension VNRecognizedTextObservation {
    public var topRecognizedText: VNRecognizedText? { topCandidates(1).first }
}
