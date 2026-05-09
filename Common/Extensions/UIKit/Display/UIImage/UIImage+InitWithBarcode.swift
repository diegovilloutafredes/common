//
//  UIImage+InitWithBarcode.swift
//

import UIKit

extension UIImage {
    
    /// Initializes an image from a barcode string using Code128 format.
    /// - Parameter barcode: The barcode string to encode.
    public convenience init?(barcode: String) {
        guard let filter = CIFilter(name: "CICode128BarcodeGenerator") else { return nil }
        let data = barcode.data(using: .ascii)
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue(0, forKey: "inputQuietSpace")
        let transform = CGAffineTransform(scaleX: 3, y: 3)
        guard let ciImage = filter.outputImage?.transformed(by: transform) else { return nil }
        self.init(ciImage: ciImage)
    }
}
