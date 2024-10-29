//
//  UITextField+AddToggleVisibilityButton.swift
//

import UIKit

extension UITextField {
    @discardableResult public func addToggleVisibilityButton(
        using visiblePasswordIcon: UIImage? = .symbol("eye.fill"),
        notVisibleVisiblePasswordIcon: UIImage? = .symbol("eye.slash.fill"),
        tintColor: UIColor? = .black
    ) -> Self {
        with {
            guard
                let visiblePasswordIcon,
                let notVisibleVisiblePasswordIcon
            else { return }

            $0.isSecureTextEntry = true
            $0.clearButtonMode = .never

            let rightButton = UIButton()
                .image(visiblePasswordIcon)
                .image(notVisibleVisiblePasswordIcon, for: .selected)
                .setRatio()
                .tintColor(tintColor)

            rightButton.addTarget($0, action: #selector(onRightButtonPressed(sender:)), for: .touchUpInside)

            $0.rightViewMode = .always
            $0.rightView = rightButton
        }
    }

    @objc private func onRightButtonPressed(sender: UIButton) {
        isSecureTextEntry.toggle()
        sender.isSelected.toggle()

        if let existingText = text, isSecureTextEntry {
            deleteBackward()
            if let textRange = textRange(from: beginningOfDocument, to: endOfDocument) {
                replace(textRange, withText: existingText)
            }
        }

        if let existingSelectedTextRange = selectedTextRange {
            selectedTextRange = nil
            selectedTextRange = existingSelectedTextRange
        }
    }
}
