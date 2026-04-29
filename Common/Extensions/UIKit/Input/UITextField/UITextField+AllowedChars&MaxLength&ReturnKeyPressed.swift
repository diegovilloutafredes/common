//
//  UITextField+AllowedChars&MaxLength&ReturnKeyPressed.swift
//

import UIKit

extension UITextField {
    
    /// Sets the allowed characters for input and returns self (chainable).
    /// - Parameter allowedChars: A string containing allowed characters, or nil for no restriction.
    @discardableResult public func allowedChars(_ allowedChars: String? = nil) -> Self {
        with { $0.allowedChars = allowedChars }
    }
}

extension UITextField {
    
    /// Sets the maximum character length and returns self (chainable).
    /// - Parameter maxLength: The maximum number of characters allowed.
    @discardableResult public func maxLength(_ maxLength: Int) -> Self {
        with { $0.maxLength = maxLength }
    }
}

extension UITextField {
    
    /// Sets a handler for when the return key is pressed and returns self (chainable).
    /// - Parameter onReturnKeyPressed: The handler to execute.
    @discardableResult public func onReturnKeyPressed(_ onReturnKeyPressed: @escaping Handler<UITextField>) -> Self {
        with { $0.onReturnKeyPressed = onReturnKeyPressed }
    }
}

extension UITextField: @retroactive UITextFieldDelegate {
    private func allowedIntoTextField(text: String) -> Bool {
        guard let allowedChars else { return text.count <= maxLength }
        return text.count <= maxLength && text.containsOnlyCharactersIn(matchCharacters: allowedChars)
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard string.isNotEmpty else { return true }
        let currentText = textField.text ?? .empty
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
        return allowedIntoTextField(text: prospectiveText)
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onReturnKeyPressed?(self)
        return onReturnKeyPressed.isNotNil
    }
}

// MARK: - Convenience
private var uiTextFieldAllowedCharsKey: UInt8 = 0
private var uiTextFieldMaxLengthKey: UInt8 = 0
private var uiTextFieldOnReturnKeyPressedKey: UInt8 = 0

extension UITextField {
    private var allowedChars: String? {
        get { objc_getAssociatedObject(self, &uiTextFieldAllowedCharsKey) as? String }
        set {
            delegate = self
            autocorrectionType = .no
            objc_setAssociatedObject(self, &uiTextFieldAllowedCharsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension UITextField {
    private var maxLength: Int {
        get { objc_getAssociatedObject(self, &uiTextFieldMaxLengthKey) as? Int ?? Int.max }
        set {
            delegate = self
            objc_setAssociatedObject(self, &uiTextFieldMaxLengthKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension UITextField {
    private var onReturnKeyPressed: Handler<UITextField>? {
        get { objc_getAssociatedObject(self, &uiTextFieldOnReturnKeyPressedKey) as? Handler<UITextField> }
        set {
            delegate = self
            objc_setAssociatedObject(self, &uiTextFieldOnReturnKeyPressedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
