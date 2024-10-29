//
//  UIImage+Init.swift
//

import UIKit

extension UIImage {
    public convenience init?(_ named: String, in bundle: Bundle = .main) {
        self.init(named: named, in: bundle, with: nil)
    }
}
