//
//  ReloadContentRequestable.swift
//

// MARK: - ReloadContentRequestable
/// A protocol for objects that can request to reload their content.
/// - Note: Legacy: in new modules the ViewModel reloads itself, from an intent or a `ViewLifecycleable` hook, and the view controller re-renders the observed state in `updateContent()` (guide §6).
public protocol ReloadContentRequestable: AnyObject {
    
    /// Notifies the object that a content reload has been requested.
    func onReloadContentRequested()
}
