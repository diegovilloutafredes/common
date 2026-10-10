//
//  Actionable.swift
//

// MARK: - Actionable
/// A protocol for objects that can perform an action.
@available(*, deprecated, message: "No replacement: declare an action closure on the type that needs one.")
public protocol Actionable {
    
    /// The action to be performed.
    var onAction: Action { get }
}
