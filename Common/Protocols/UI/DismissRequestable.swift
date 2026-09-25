//
//  DismissRequestable.swift
//

// MARK: - DismissRequestable
/// A protocol for objects that can request to be dismissed.
/// - Note: Legacy: a new module fires `onRequested` (or `onPerformed` when its work is done) and the coordinator dismisses (guide §6).
@MainActor
public protocol DismissRequestable: AnyObject {
    
    /// Notifies the object that a dismissal has been requested.
    func onDismissRequested()
}
