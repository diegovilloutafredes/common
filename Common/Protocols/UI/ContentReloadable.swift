//
//  ContentReloadable.swift
//

// MARK: - ContentReloadable
/// A protocol for objects that can reload their content.
/// - Note: Legacy: in new modules the ViewModel reloads itself, from an intent or a `ViewLifecycleable` hook, and the view controller re-renders the observed state in `updateContent()` (guide §6).
public protocol ContentReloadable {
    
    /// Reloads the content of the object.
    func reloadContent()
}
