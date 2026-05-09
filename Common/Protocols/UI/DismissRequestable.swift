//
//  DismissRequestable.swift
//

// MARK: - DismissRequestable
/// A protocol for objects that can request to be dismissed.
@MainActor
public protocol DismissRequestable: AnyObject {
    
    /// Notifies the object that a dismissal has been requested.
    func onDismissRequested()
}
