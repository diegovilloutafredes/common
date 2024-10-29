//
//  UIImage+ConvertToGrayScale.swift
//

import UIKit

extension UIImage {
    public func convertToGrayScale() -> UIImage {
        // Create image rectangle with current image width/height
        let imageRect = CGRect(x:.zero, y:.zero, width: size.width, height: size.height)

        // Grayscale color space
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let width = size.width
        let height = size.height

        // Create bitmap content with current image size and grayscale colorspace
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)

        // Draw image into current context, with specified rectangle
        // using previously defined context (with grayscale colorspace)
        let context = CGContext(
            data: nil,
            width: .init(width),
            height: .init(height),
            bitsPerComponent: 8,
            bytesPerRow: .zero,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        )

        context?.draw(cgImage!, in: imageRect)

        let imageRef = context!.makeImage()!

        return .init(cgImage: imageRef)
    }
}
