//
//  DismissRequestable.swift
//

// MARK: - DismissRequestable
// MARK: - DismissRequestable
/// A protocol for objects that can request to be dismissed.
public protocol DismissRequestable: AnyObject {
    
    /// Notifies the object that a dismissal has been requested.
    func onDismissRequested()
}
