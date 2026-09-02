//
//  ViewLifecycleable.swift
//

// MARK: - ViewLifecycleable
/// A protocol for objects that can respond to view lifecycle events.
@MainActor
public protocol ViewLifecycleable: AnyObject {
    
    /// Notifies the object that its view has been loaded.
    func onViewDidLoad()
    
    /// Notifies the object that its view is about to appear.
    func onViewWillAppear()
    
    /// Notifies the object that its view is appearing.
    func onViewIsAppearing()
    
    /// Notifies the object that its view is about to layout subviews.
    func onViewWillLayoutSubviews()
    
    /// Notifies the object that its view has finished laying out subviews.
    func onViewDidLayoutSubviews()

    /// Called on every content-update pass. Read observable state here and push it into
    /// the view. On iOS 26 this is UIKit's `updateProperties()`; on iOS 17–18 Common re-runs
    /// it when any `@Observable` property read inside changes. See `ObservationMode`.
    func onUpdateProperties()

    /// Notifies the object that its view has appeared.
    func onViewDidAppear()
    
    /// Notifies the object that its view is about to disappear.
    func onViewWillDisappear()

    /// Notifies the object that its view has disappeared.
    func onViewDidDisappear()
}

// MARK: - Default Impl
extension ViewLifecycleable {
    public func onViewDidLoad() {}
    public func onViewWillAppear() {}
    public func onViewIsAppearing() {}
    public func onViewWillLayoutSubviews() {}
    public func onViewDidLayoutSubviews() {}
    public func onUpdateProperties() {}
    public func onViewDidAppear() {}
    public func onViewWillDisappear() {}
    public func onViewDidDisappear() {}
}
