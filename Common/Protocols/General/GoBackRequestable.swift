//
//  GoBackRequestable.swift
//

// MARK: - GoBackRequestable
/// A protocol for objects that can request to navigate back in a navigation stack.
@MainActor
public protocol GoBackRequestable: AnyObject {
    
    /// Notifies the object that a "go back" navigation has been requested.
    func onGoBackRequested()
}
