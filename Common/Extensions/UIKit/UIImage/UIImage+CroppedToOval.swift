//
//  UIImage+CroppedToOval.swift
//

import UIKit

// MARK: - Cropped to oval
extension UIImage {
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
