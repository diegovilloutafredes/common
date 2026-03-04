//
//  ViewLifecycleable.swift
//

// MARK: - ViewLifecycleable
// MARK: - ViewLifecycleable
/// A protocol for objects that can respond to view lifecycle events.
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
    
    /// Notifies the object that its view has appeared.
    func onViewDidAppear()
    
    /// Notifies the object that its view is about to disappear.
    func onViewWillDisappear()
}

// MARK: - Default Impl
extension ViewLifecycleable {
    public func onViewDidLoad() {}
    public func onViewWillAppear() {}
    public func onViewIsAppearing() {}
    public func onViewWillLayoutSubviews() {}
    public func onViewDidLayoutSubviews() {}
    public func onViewDidAppear() {}
    public func onViewWillDisappear() {}
}
