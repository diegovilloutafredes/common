//
//  UILabel+OnTap.swift
//

import UIKit

extension UILabel {
    private var onTapHandler: Handler<(UILabel, UITapGestureRecognizer)>? {
        get { associatedObject(for: "onTapHandler") as? Handler<(UILabel, UITapGestureRecognizer)> }
        set { set(associatedObject: newValue, for: "onTapHandler") }
    }

    @discardableResult public func onTextTap(_ handler: @escaping Handler<(UILabel, UITapGestureRecognizer)>) -> Self {
        with {
            $0.onTapHandler = handler
            let gesture = UITapGestureRecognizer(target: self, action: #selector(onTextTapped(sender:)))
                .numberOfTapsRequired(1)
            addGestureRecognizer(gesture)
        }
    }

    @objc private func onTextTapped(sender: UITapGestureRecognizer) {
        onTapHandler?((self, sender))
    }
}
