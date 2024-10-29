//
//  Withable.swift
//

import Foundation

// MARK: - Withable for Objects
public protocol Withable: AnyObject {
    associatedtype T // swiftlint:disable:this type_name
    /// Provides a closure to configure instances inline.
    /// - Parameter closure: A closure `self` as the argument.
    /// - Returns: Simply returns the instance after called the `closure`.
    @discardableResult func with(_ closure: (_ instance: T) -> Void) -> T
}

extension Withable {
    @discardableResult public func with(_ closure: (_ instance: Self) -> Void) -> Self {
        closure(self)
        return self
    }
}
