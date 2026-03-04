//
//  UIImage+Named.swift
//

import UIKit

extension UIImage {
    
    /// Returns an image from the specified bundle by name.
    /// - Parameters:
    ///   - named: The name of the image.
    ///   - bundle: The bundle containing the image. Defaults to `.main`.
    /// - Returns: The image, or `nil` if not found.
    public static func named(_ named: String, in bundle: Bundle = .main) -> UIImage? { .init(named, in: bundle) }
}
