//
//  UITextField+ContentType.swift
//

import UIKit

extension UITextField {
    @discardableResult public func contentType(_ contentType: UITextContentType) -> Self {
        with { $0.textContentType = contentType }
    }
}
