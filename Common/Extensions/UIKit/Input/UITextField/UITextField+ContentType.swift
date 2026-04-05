//
//  UITextField+ContentType.swift
//

import UIKit

extension UITextField {
    
    /// Sets the text content type and returns self (chainable).
    /// - Parameter contentType: The content type to set.
    @discardableResult public func contentType(_ contentType: UITextContentType) -> Self {
        with { $0.textContentType = contentType }
    }
}
