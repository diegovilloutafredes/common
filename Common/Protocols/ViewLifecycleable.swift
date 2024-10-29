//
//  ViewLifecycleable.swift
//

// MARK: - ViewLifecycleable
public protocol ViewLifecycleable: AnyObject {
    func onViewDidLoad()
    func onViewWillAppear()
    func onViewIsAppearing()
    func onViewWillLayoutSubviews()
    func onViewDidLayoutSubviews()
    func onViewDidAppear()
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
