//
//  UIView+OnTap.swift
//

import UIKit

private var onTapHandlerKey: UInt8 = 0
private var onTapGestureRecognizerKey: UInt8 = 0

extension UIView {
    private var onTapHandler: Handler<(UIView, UITapGestureRecognizer)>? {
        get { objc_getAssociatedObject(self, &onTapHandlerKey) as? Handler<(UIView, UITapGestureRecognizer)> }
        set { objc_setAssociatedObject(self, &onTapHandlerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    private var onTapGestureRecognizer: UITapGestureRecognizer? {
        get { objc_getAssociatedObject(self, &onTapGestureRecognizerKey) as? UITapGestureRecognizer }
        set { objc_setAssociatedObject(self, &onTapGestureRecognizerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    /// Adds a tap gesture handler and returns self (chainable).
    /// Replaces any previously registered handler and its gesture recognizer.
    /// - Parameter handler: The handler to execute with view and gesture.
    @discardableResult public func onTap(_ handler: @escaping Handler<(UIView, UITapGestureRecognizer)>) -> Self {
        with {
            if let old = $0.onTapGestureRecognizer { $0.removeGestureRecognizer(old) }
            $0.onTapHandler = handler
            let gesture = UITapGestureRecognizer(target: $0, action: #selector(onTapped(sender:)))
                .numberOfTapsRequired(1)
            $0.addGestureRecognizer(gesture)
            $0.onTapGestureRecognizer = gesture
        }
    }

    @objc private func onTapped(sender: UITapGestureRecognizer) {
        onTapHandler?((self, sender))
    }
}
