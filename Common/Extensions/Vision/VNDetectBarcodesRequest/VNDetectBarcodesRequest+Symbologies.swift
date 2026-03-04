//
//  VNDetectBarcodesRequest+Symbologies.swift
//

import Vision

extension VNDetectBarcodesRequest {
    
    /// Sets the barcode symbologies to detect and returns self (chainable).
    /// - Parameter symbologies: The list of symbologies to detect.
    @discardableResult public func symbologies(_ symbologies: [VNBarcodeSymbology]) -> Self {
        with { $0.symbologies = symbologies }
    }
}
