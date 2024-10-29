//
//  UITextField+AddRightButton.swift
//

import UIKit

extension UITextField {
    private var onButtonPressed: Handler<(UITextField, UIButton)>? {
        get { associatedObject(for: "onButtonPressed") as? Handler<(UITextField, UIButton)> }
        set {
            delegate = self
            set(associatedObject: newValue, for: "onButtonPressed")
        }
    }
}

extension UITextField {
    @discardableResult public func addRightButton(
        using icon: UIImage? = .symbol("arrowtriangle.up.fill"),//.named("ArrowDown")
        selectedIcon: UIImage? = .symbol("arrowtriangle.down.fill"),//.named("ArrowDown")
        tintColor: UIColor? = .black,
        onButtonPressed: @escaping Handler<(UITextField, UIButton)>
    ) -> Self {
        with {
            guard
                let icon,
                let selectedIcon
            else { return }

            $0.onButtonPressed = onButtonPressed
            $0.clearButtonMode = .never

            let rightButton = UIButton()
                .image(icon)
                .image(selectedIcon, for: .selected)
                .setRatio()
                .tintColor(tintColor)
                .setConstraints {
                    ($0 as? UIButton)?
                        .imageView?
                        .setRatio()
                        .setWidth(to: $1.widthAnchor, multiplier: 0.3)
                }

            rightButton.addTarget($0, action: #selector(onButtonPressed(sender:)), for: .touchUpInside)

            $0.rightView(HStack(alignment: .center) { rightButton })
        }
    }

    @objc private func onButtonPressed(sender: UIButton) {
        onButtonPressed?((self, sender))
    }
}
