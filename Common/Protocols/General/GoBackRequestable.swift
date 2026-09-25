//
//  GoBackRequestable.swift
//

// MARK: - GoBackRequestable
/// A protocol for objects that can request to navigate back in a navigation stack.
/// - Note: Legacy: a new module fires `onRequested(.goBack)` and the coordinator pops (guide §6).
@MainActor
public protocol GoBackRequestable: AnyObject {
    
    /// Notifies the object that a "go back" navigation has been requested.
    func onGoBackRequested()
}
