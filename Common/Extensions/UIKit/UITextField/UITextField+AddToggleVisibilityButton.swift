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
                .onTap { self.onTapped($0.0 as! UIButton) }

            $0.rightView(
                HStack(alignment: .center) {
                    rightButton
                    UIView()
                        .setRatio()
                        .setConstraints { $0.set(width: 16) }
                }
            )
        }
    }

    private func onTapped(_ button: UIButton) {
        isSecureTextEntry.toggle()
        button.isSelected.toggle()

        if
            let existingText = text,
            isSecureTextEntry {
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
