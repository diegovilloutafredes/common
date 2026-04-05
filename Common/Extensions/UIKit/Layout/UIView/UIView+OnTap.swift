//
//  UIView+OnTap.swift
//

import UIKit

extension UIView {
    private var onTapHandler: Handler<(UIView, UITapGestureRecognizer)>? {
        get { associatedObject(for: "onTapHandler") as? Handler<(UIView, UITapGestureRecognizer)> }
        set { set(associatedObject: newValue, for: "onTapHandler") }
    }

    /// Adds a tap gesture handler and returns self (chainable).
    /// - Parameter handler: The handler to execute with view and gesture.
    @discardableResult public func onTap(_ handler: @escaping Handler<(UIView, UITapGestureRecognizer)>) -> Self {
        with {
            $0.onTapHandler = handler
            let gesture = UITapGestureRecognizer(target: self, action: #selector(onTapped(sender:)))
                .numberOfTapsRequired(1)
            addGestureRecognizer(gesture)
        }
    }

    @objc private func onTapped(sender: UITapGestureRecognizer) {
        onTapHandler?((self, sender))
    }
}
