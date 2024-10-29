//
//  VNDetectBarcodesRequest+Symbologies.swift
//

import Vision

extension VNDetectBarcodesRequest {
    @discardableResult public func symbologies(_ symbologies: [VNBarcodeSymbology]) -> Self {
        with { $0.symbologies = symbologies }
    }
}
