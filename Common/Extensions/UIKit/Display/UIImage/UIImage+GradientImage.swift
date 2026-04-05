//
//  UIImage+GradientImage.swift
//

import UIKit

extension UIImage {
    
    /// Creates a gradient image with the specified colors and size.
    /// - Parameters:
    ///   - colors: Array of CGColors for the gradient.
    ///   - locations: Gradient stop locations. Defaults to `[0, 0.5]`.
    ///   - size: The size of the resulting image.
    /// - Returns: The gradient image, or `nil` if creation fails.
    static public func gradientImage(using colors: [CGColor], locations: [Float] = [.zero, 0.5], size: CGSize) -> UIImage? {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = .init(x: .zero, y: .zero, width: size.width, height: size.height)
        gradientLayer.colors = colors
        gradientLayer.cornerRadius = gradientLayer.frame.height / 2
        gradientLayer.masksToBounds = false

        gradientLayer.startPoint = .init(x: 0.5, y: 1.0)
        gradientLayer.endPoint   = .init(x: 0.5, y: .zero)

        gradientLayer.locations = locations.map { .init(value: $0) }

        UIGraphicsBeginImageContext(size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        gradientLayer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()?
            .resizableImage(withCapInsets: .init(top: .zero, left: size.height, bottom: .zero, right: size.height))
        UIGraphicsEndImageContext()

        return image
    }
}
