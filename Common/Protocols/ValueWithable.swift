//
//  ValueWithable.swift
//

import Foundation

// MARK: - Withable for Values
public protocol ValueWithable {
    associatedtype T // swiftlint:disable:this type_name
    /// Provides a closure to configure instances inline.
    /// - Parameter closure: A closure with a mutable copy of `self` as the argument.
    /// - Returns: Simply returns the mutated copy of the instance after called the `closure`.
    @discardableResult func with(_ closure: (_ instance: inout T) -> Void) -> T
}

extension ValueWithable {
    @discardableResult public func with(_ closure: (_ instance: inout Self) -> Void) -> Self {
        var copy = self
        closure(&copy)
        return copy
    }
}
