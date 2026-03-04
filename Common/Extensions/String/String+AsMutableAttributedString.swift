//
//  String+AsMutableAttributedString.swift
//

import Foundation

extension String {
    
    /// Creates a mutable attributed string from the string.
    public var asMutableAttributedString: NSMutableAttributedString { .init(string: self) }
    
    /// Creates a mutable attributed string with specific attributes.
    /// - Parameter attributes: The attributes to apply.
    /// - Returns: The mutable attributed string.
    public func asMutableAttributedString(_ attributes: [NSAttributedString.Key: Any]) -> NSMutableAttributedString { .init(string: self, attributes: attributes) }
}
