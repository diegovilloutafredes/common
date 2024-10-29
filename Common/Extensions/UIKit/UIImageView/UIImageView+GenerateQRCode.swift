//
//  UIImageView+GenerateQRCode.swift
//

import UIKit

// MARK: - Generate QRCode
extension UIImageView {
    public func generateQRCode(from string: String) {
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return }

        let data = string.data(using: .ascii)
        
        filter.setValue(data, forKey: "inputMessage")

        guard let outputImage = filter.outputImage else { return }

        let scaleX = frame.size.width / outputImage.extent.size.width
        let scaleY = frame.size.height / outputImage.extent.size.height

        let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        
        let transformedOutputImage = outputImage.transformed(by: transform)

        image = UIImage(ciImage: transformedOutputImage)
    }
}
