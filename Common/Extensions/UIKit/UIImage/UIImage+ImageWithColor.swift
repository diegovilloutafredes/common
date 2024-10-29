//
//  UIImage+ImageWithColor.swift
//

import UIKit

// MARK: - image(with color: UIColor)
extension UIImage {
    public func image(with color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)

        guard
            let context = UIGraphicsGetCurrentContext(),
            let cgImage = cgImage 
        else { return nil }

        context.translateBy(x: .zero, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(.normal)
        
        let rect = CGRect(x: .zero, y: .zero, width: size.width, height: size.height)

        context.clip(to: rect, mask: cgImage)
        color.setFill()
        context.fill(rect)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}
