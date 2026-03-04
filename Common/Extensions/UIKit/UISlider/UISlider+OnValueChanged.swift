//
//  UISlider+OnValueChanged.swift
//

import UIKit

extension UISlider {
    private var onValueChangedHandler: Handler<Float>? {
        get { associatedObject(for: "onValueChangedHandler") as? Handler<Float> }
        set { set(associatedObject: newValue, for: "onValueChangedHandler") }
    }

    /// Sets a handler for value changed events and returns self (chainable).
    /// - Parameter handler: The closure to execute with the new value.
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
    
    /// Sets the minimum value and returns self (chainable).
    /// - Parameter minimumValue: The minimum slider value.
    @discardableResult public func minimumValue(_ minimumValue: Float) -> Self {
        with { $0.minimumValue = minimumValue }
    }

    /// Sets the maximum value and returns self (chainable).
    /// - Parameter maximumValue: The maximum slider value.
    @discardableResult public func maximumValue(_ maximumValue: Float) -> Self {
        with { $0.maximumValue = maximumValue }
    }

    /// Sets the minimum track tint color and returns self (chainable).
    /// - Parameter minimumTrackTintColor: The color for the filled portion.
    @discardableResult public func minimumTrackTintColor(_ minimumTrackTintColor: UIColor) -> Self {
        with { $0.minimumTrackTintColor = minimumTrackTintColor }
    }

    /// Sets the maximum track tint color and returns self (chainable).
    /// - Parameter maximumTrackTintColor: The color for the unfilled portion.
    @discardableResult public func maximumTrackTintColor(_ maximumTrackTintColor: UIColor) -> Self {
        with { $0.maximumTrackTintColor = maximumTrackTintColor }
    }

    /// Sets the slider value and returns self (chainable).
    /// - Parameters:
    ///   - value: The value to set.
    ///   - animated: Whether to animate the change. Defaults to `true`.
    @discardableResult public func value(_ value: Float, animated: Bool = true) -> Self {
        with { $0.setValue(value, animated: animated) }
    }
}
