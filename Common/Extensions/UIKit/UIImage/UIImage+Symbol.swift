//
//  UIImage+Symbol.swift
//

import UIKit

extension UIImage {
    public static func symbol(_ named: String, configuration: UIImage.SymbolConfiguration? = nil) -> UIImage? {
        .init(systemName: named, withConfiguration: configuration)
    }
}

@available(iOS 16.0, *)
extension UIImage {
    public static func symbol(_ named: String, variableValue: Double = .zero, configuration: UIImage.SymbolConfiguration? = nil) -> UIImage? {
        .init(systemName: named, variableValue: variableValue, configuration: configuration)
    }
}
