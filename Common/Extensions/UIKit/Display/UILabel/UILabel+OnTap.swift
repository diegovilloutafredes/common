//
//  UILabel+OnTap.swift
//

import UIKit

nonisolated(unsafe) private var uiLabelOnTapHandlerKey: UInt8 = 0
nonisolated(unsafe) private var uiLabelOnTapGestureRecognizerKey: UInt8 = 0

extension UILabel {
    private var onTapHandler: Handler<(UILabel, UITapGestureRecognizer)>? {
        get { objc_getAssociatedObject(self, &uiLabelOnTapHandlerKey) as? Handler<(UILabel, UITapGestureRecognizer)> }
        set { objc_setAssociatedObject(self, &uiLabelOnTapHandlerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    private var onTapGestureRecognizer: UITapGestureRecognizer? {
        get { objc_getAssociatedObject(self, &uiLabelOnTapGestureRecognizerKey) as? UITapGestureRecognizer }
        set { objc_setAssociatedObject(self, &uiLabelOnTapGestureRecognizerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    /// Adds a tap gesture handler for the label text.
    /// Replaces any previously registered handler and its gesture recognizer.
    /// - Parameter handler: The closure to execute when tapped, receiving the label and gesture.
    @discardableResult public func onTextTap(_ handler: @escaping Handler<(UILabel, UITapGestureRecognizer)>) -> Self {
        with {
            if let old = $0.onTapGestureRecognizer { $0.removeGestureRecognizer(old) }
            $0.onTapHandler = handler
            let gesture = UITapGestureRecognizer(target: $0, action: #selector(onTextTapped(sender:)))
                .numberOfTapsRequired(1)
            $0.addGestureRecognizer(gesture)
            $0.onTapGestureRecognizer = gesture
        }
    }

    @objc private func onTextTapped(sender: UITapGestureRecognizer) {
        onTapHandler?((self, sender))
    }
}
