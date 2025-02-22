//
//  UIImage+InitWithBarcode.swift
//  UniPay
//

import UIKit

extension UIImage {
    convenience init?(barcode: String) {
        guard let filter = CIFilter(name: "CICode128BarcodeGenerator") else { return nil }

        let data = barcode.data(using: .ascii)

        filter.setValue(data, forKey: "inputMessage")
        filter.setValue(0, forKey: "inputQuietSpace")

        let transform = CGAffineTransform(scaleX: 3, y: 3)

        guard let ciImage = filter.outputImage?.transformed(by: transform) else { return nil }

        self.init(ciImage: ciImage)
    }
}
