//
//  UIImage+Named.swift
//

import UIKit

extension UIImage {
    public static func named(_ named: String, in bundle: Bundle = .main) -> UIImage? { .init(named, in: bundle) }
}
