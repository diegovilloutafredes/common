//
//  ReloadContentRequestable.swift
//

// MARK: - ReloadContentRequestable
// MARK: - ReloadContentRequestable
/// A protocol for objects that can request to reload their content.
public protocol ReloadContentRequestable: AnyObject {
    
    /// Notifies the object that a content reload has been requested.
    func onReloadContentRequested()
}
