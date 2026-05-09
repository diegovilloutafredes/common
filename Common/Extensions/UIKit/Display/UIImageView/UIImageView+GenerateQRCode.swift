//
//  UIImageView+GenerateQRCode.swift
//

import UIKit

// MARK: - Generate QRCode
extension UIImageView {
    
    /// Generates a QR code image from the specified string and sets it as the image.
    /// - Parameter string: The string to encode as a QR code.
    public func generateQRCode(using string: String) {
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return }
        let data = string.data(using: .ascii)
        filter.setValue(data, forKey: "inputMessage")
        guard let outputImage = filter.outputImage else { return }
        let scaleX = frame.size.width / outputImage.extent.size.width
        let scaleY = frame.size.height / outputImage.extent.size.height
        let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        let transformedOutputImage = outputImage.transformed(by: transform)
        image = .init(ciImage: transformedOutputImage)
    }
}
