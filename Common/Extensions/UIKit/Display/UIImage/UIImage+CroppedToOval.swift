//
//  UIImage+CroppedToOval.swift
//

import UIKit

// MARK: - Cropped to oval
extension UIImage {
    
    /// Crops the image to an oval shape within the specified rectangle.
    /// - Parameter rect: The rectangle defining the oval bounds.
    /// - Returns: The cropped oval image.
    public func croppedToOval(in rect: CGRect) -> UIImage {
        let path = UIBezierPath(ovalIn: rect)

        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()!
        context.saveGState()
        
        // Set the clipping mask
        path.addClip()

        draw(in: .init(x: .zero, y: .zero, width: size.width, height: size.height))

        guard let maskedImage = UIGraphicsGetImageFromCurrentImageContext() else { return self }

        // Restore previous drawing context
        context.restoreGState()
        UIGraphicsEndImageContext()

        return .init(cgImage: maskedImage.cgImage!.cropping(to: path.bounds)!)
    }
}
