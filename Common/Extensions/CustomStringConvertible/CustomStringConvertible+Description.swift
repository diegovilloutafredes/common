//
//  CustomStringConvertible+Description.swift
//

import Foundation

// MARK: - CustomStringConvertible
extension CustomStringConvertible {
    
    /// Returns a string description of the object using Mirror to reflect its properties.
    @available(*, deprecated, message: "Adopt MirrorDescribable for this output, or implement description.")
    public var description: String { mirrorDescription(of: self) }
}
