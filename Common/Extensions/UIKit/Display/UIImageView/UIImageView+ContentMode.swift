//
//  UIImageView+ContentMode.swift
//

import UIKit

extension UIImageView {
    
    /// Sets the content mode and returns self (chainable).
    /// - Parameter contentMode: The content mode to set.
    @discardableResult public func contentMode(_ contentMode: ContentMode) -> Self {
        with { $0.contentMode = contentMode }
    }
}
