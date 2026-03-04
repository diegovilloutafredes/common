//
//  UIImage+Init.swift
//

import UIKit

extension UIImage {
    
    /// Initializes an image from the specified bundle.
    /// - Parameters:
    ///   - named: The name of the image.
    ///   - bundle: The bundle containing the image. Defaults to `.main`.
    public convenience init?(_ named: String, in bundle: Bundle = .main) {
        self.init(named: named, in: bundle, with: nil)
    }
}
