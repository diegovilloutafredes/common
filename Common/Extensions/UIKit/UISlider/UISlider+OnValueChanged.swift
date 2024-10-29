//
//  UISlider+OnValueChanged.swift
//

import UIKit

extension UISlider {
    private var onValueChangedHandler: Handler<Float>? {
        get { associatedObject(for: "onValueChangedHandler") as? Handler<Float> }
        set { set(associatedObject: newValue, for: "onValueChangedHandler") }
    }

    @discardableResult public func onValueChanged(_ handler: @escaping Handler<Float>) -> Self {
        with {
            $0.onValueChangedHandler = handler
            addTarget($0, action: #selector(valueChanged(sender:)), for: .valueChanged)
        }
    }

    @objc private func valueChanged(sender: UISlider) {
        onValueChangedHandler?(sender.value)
    }
}

extension UISlider {
    @discardableResult public func minimumValue(_ minimumValue: Float) -> Self {
        with { $0.minimumValue = minimumValue }
    }

    @discardableResult public func maximumValue(_ maximumValue: Float) -> Self {
        with { $0.maximumValue = maximumValue }
    }

    @discardableResult public func minimumTrackTintColor(_ minimumTrackTintColor: UIColor) -> Self {
        with { $0.minimumTrackTintColor = minimumTrackTintColor }
    }

    @discardableResult public func maximumTrackTintColor(_ maximumTrackTintColor: UIColor) -> Self {
        with { $0.maximumTrackTintColor = maximumTrackTintColor }
    }

    @discardableResult public func value(_ value: Float, animated: Bool = true) -> Self {
        with { $0.setValue(value, animated: animated) }
    }
}
