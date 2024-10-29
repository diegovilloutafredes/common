//
//  UIImage+CroppedTo.swift
//

import UIKit

// MARK: - Cropped to
extension UIImage {
    public func cropped(to boundingBox: CGRect) -> UIImage? {
        guard let cgImage = cgImage?.cropping(to: boundingBox) else { return nil }
        return .init(cgImage: cgImage)
    }
}
