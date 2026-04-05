//
//  UIImage+Symbol.swift
//

import UIKit

extension UIImage {
    
    /// Returns a SF Symbol image by name.
    /// - Parameters:
    ///   - named: The symbol name.
    ///   - configuration: Optional symbol configuration.
    /// - Returns: The symbol image, or `nil` if not found.
    public static func symbol(_ named: String, configuration: UIImage.SymbolConfiguration? = nil) -> UIImage? {
        .init(systemName: named, withConfiguration: configuration)
    }
}

@available(iOS 16.0, *)
extension UIImage {
    
    /// Returns a SF Symbol image with a variable value (iOS 16+).
    /// - Parameters:
    ///   - named: The symbol name.
    ///   - variableValue: The variable value for the symbol. Defaults to 0.
    ///   - configuration: Optional symbol configuration.
    /// - Returns: The symbol image, or `nil` if not found.
    public static func symbol(_ named: String, variableValue: Double = .zero, configuration: UIImage.SymbolConfiguration? = nil) -> UIImage? {
        .init(systemName: named, variableValue: variableValue, configuration: configuration)
    }
}
