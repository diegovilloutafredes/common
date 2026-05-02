//
//  UISegmentedControl+OnValueChanged.swift
//

import UIKit

nonisolated(unsafe) private var uiSegmentedControlOnValueChangedKey: UInt8 = 0

extension UISegmentedControl {
    private var onValueChangedHandler: Handler<Int>? {
        get { objc_getAssociatedObject(self, &uiSegmentedControlOnValueChangedKey) as? Handler<Int> }
        set { objc_setAssociatedObject(self, &uiSegmentedControlOnValueChangedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    /// Sets a handler for value changed events and returns self (chainable).
    /// Replaces any previously registered handler.
    /// - Parameter handler: The closure to execute with the newly selected segment index.
    @discardableResult public func onValueChanged(_ handler: @escaping Handler<Int>) -> Self {
        with {
            $0.onValueChangedHandler = handler
            $0.removeTarget($0, action: #selector(valueChanged), for: .valueChanged)
            $0.addTarget($0, action: #selector(valueChanged), for: .valueChanged)
        }
    }

    @objc private func valueChanged() {
        onValueChangedHandler?(selectedSegmentIndex)
    }
}

extension UISegmentedControl {

    /// Replaces all segment titles and returns self (chainable).
    /// - Parameter items: The titles for each segment, in order.
    @discardableResult public func items(_ items: [String]) -> Self {
        with { control in
            control.removeAllSegments()
            items.enumerated().forEach { index, title in
                control.insertSegment(withTitle: title, at: index, animated: false)
            }
        }
    }

    /// Sets the selected segment index and returns self (chainable).
    /// - Parameter index: The index of the segment to select.
    @discardableResult public func selectSegment(at index: Int) -> Self {
        with { $0.selectedSegmentIndex = index }
    }

    /// Sets the tint color for the selected segment and returns self (chainable).
    /// - Parameter color: The tint color, or nil to use the default.
    @discardableResult public func selectedSegmentTintColor(_ color: UIColor?) -> Self {
        with { $0.selectedSegmentTintColor = color }
    }
}
