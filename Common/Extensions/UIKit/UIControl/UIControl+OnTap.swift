//
//  UIControl+OnTap.swift
//

import UIKit

extension UIControl {
    private var onTap: Action? {
        get { associatedObject(for: "onTapAction") as? Action }
        set { set(associatedObject: newValue, for: "onTapAction") }
    }

    @discardableResult public func onTap(_ action: @escaping Action) -> Self {
        with {
            $0.onTap = action
            addTarget($0, action: #selector(didTouchUpInside), for: .touchUpInside)
        }
    }

    @objc private func didTouchUpInside() { onTap?() }
}
