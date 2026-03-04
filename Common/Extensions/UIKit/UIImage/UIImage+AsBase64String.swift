//
//  UIImage+AsBase64String.swift
//

import UIKit

extension UIImage {
    
    /// Returns the image as a base64-encoded string (JPEG format, quality 1.0).
    public var asBase64String: String? { jpegData(compressionQuality: 1)?.base64EncodedString() }
}
