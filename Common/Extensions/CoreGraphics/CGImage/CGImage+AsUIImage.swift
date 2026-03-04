//
//  CGImage+AsUIImage.swift
//

import UIKit

extension CGImage {
    
    /// Converts the CGImage to a UIImage.
    public var asUIImage: UIImage { .init(cgImage: self) }
}
