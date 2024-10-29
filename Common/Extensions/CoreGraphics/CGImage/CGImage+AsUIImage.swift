//
//  CGImage+AsUIImage.swift
//

import UIKit

extension CGImage {
    public var asUIImage: UIImage { .init(cgImage: self) }
}
