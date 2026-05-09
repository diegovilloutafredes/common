//
//  UILabel+Init.swift
//

import UIKit

extension UILabel {
    
    /// Initializes a label with the specified text.
    /// - Parameter text: The text to display.
    public convenience init(_ text: String?) {
        self.init(frame: .zero)
        self.text(text)
    }
}
