//
//  UIImage+AsBase64String.swift
//

import UIKit

extension UIImage {
    var asBase64String: String? { jpegData(compressionQuality: 1)?.base64EncodedString() }
}
