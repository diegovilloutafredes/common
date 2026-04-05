//
//  UIImage+CroppedTo.swift
//

import UIKit

// MARK: - Cropped to
extension UIImage {
    
    /// Crops the image to the specified bounding box.
    /// - Parameter boundingBox: The rectangle to crop to.
    /// - Returns: The cropped image, or `nil` if cropping fails.
    public func cropped(to boundingBox: CGRect) -> UIImage? {
        guard let cgImage = cgImage?.cropping(to: boundingBox) else { return nil }
        return .init(cgImage: cgImage)
    }
}
