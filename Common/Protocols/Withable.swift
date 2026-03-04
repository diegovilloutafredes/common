//
//  Withable.swift
//

import Foundation

// MARK: - Withable for Objects
// MARK: - Withable for Objects
/// A protocol that provides a fluent interface for configuring reference types.
public protocol Withable: AnyObject {
    associatedtype T // swiftlint:disable:this type_name
    
    /// Provides a closure to configure instances inline.
    /// - Parameter closure: A closure with `self` as the argument.
    /// - Returns: Simply returns the instance after calling the `closure`.
    @discardableResult func with(_ closure: (_ instance: T) -> Void) -> T
}

extension Withable {
    @discardableResult public func with(_ closure: (_ instance: Self) -> Void) -> Self {
        closure(self)
        return self
    }
}
