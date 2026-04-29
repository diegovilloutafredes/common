//
//  UIControl+OnTap.swift
//

import UIKit

private var uiControlOnTapKey: UInt8 = 0

extension UIControl {
    private var onTap: Action? {
        get { objc_getAssociatedObject(self, &uiControlOnTapKey) as? Action }
        set { objc_setAssociatedObject(self, &uiControlOnTapKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    /// Adds a closure to be executed when the control is tapped (.touchUpInside).
    /// Replaces any previously registered handler.
    /// - Parameter action: The closure to execute.
    @discardableResult public func onTap(_ action: @escaping Action) -> Self {
        with {
            $0.onTap = action
            $0.removeTarget($0, action: #selector(didTouchUpInside), for: .touchUpInside)
            $0.addTarget($0, action: #selector(didTouchUpInside), for: .touchUpInside)
        }
    }

    @objc private func didTouchUpInside() { onTap?() }
}
