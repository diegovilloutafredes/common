//
//  BaseReusableView.swift
//

import UIKit

// MARK: - BaseReusableView

/// A base collection reusable view (e.g., for headers or footers) that conforms to `UIViewBuildable`.
/// It provides a consistent setup for hosting a main view.
open class BaseReusableView: UICollectionReusableView, UIViewBuildable {
    
    /// The main view of the reusable view.
    /// Subclasses should override this to provide their custom view hierarchy.
    /// By default, returns an empty `UIView`.
    @UIViewBuilder
    open var mainView: UIView { UIView() }

    /// Installs `mainView` the way `BaseView` does: constraints the root declares with
    /// `setConstraints` are the ones applied (declare all four edges), and a root that declares none
    /// is pinned edge to edge.
    override public init(frame: CGRect) {
        super.init(frame: frame)
        let content = mainView
        addSubview(content)
        // setConstraints handlers fire synchronously during addSubview (via didMoveToSuperview).
        // If the subclass already set up constraints, TAMIC is false — skip to avoid duplicates.
        if content.translatesAutoresizingMaskIntoConstraints { content.snap(to: self) }
        setupView()
    }

    @available(*, unavailable)
    required public init(coder aDecoder: NSCoder) {
        fatalError("NSCoder is not supported")
    }

    public override class var requiresConstraintBasedLayout: Bool { true }

    /// Sets up the view.
    /// Override this method to perform additional configuration during initialization.
    open func setupView() {}

    /// Pushes state into subviews. Override to read `viewModel` or any `@Observable` model here.
    ///
    /// On iOS 26 UIKit calls this from `updateProperties()` and re-runs it when any
    /// `@Observable` property read inside changes. On iOS 17–18 Common calls it from
    /// `layoutSubviews()` under `withObservationTracking` with the same effect.
    /// Do not call it directly; call `setNeedsContentUpdate()`.
    open func updateContent() {}

    /// Schedules `updateContent()` for the next update pass.
    public func setNeedsContentUpdate() { scheduleContentUpdate() }

    /// Runs a pending `updateContent()` now instead of waiting for the next update pass.
    ///
    /// The view-model-able subclasses call this right after `viewModel` is assigned: self-sizing
    /// cells are measured immediately after configuration, before any layout or properties pass,
    /// so the content has to be bound synchronously. Tracking is armed by that run, and later
    /// observable changes are still delivered on the next pass.
    public func updateContentIfNeeded() { flushContentUpdateIfNeeded() }

    /// See `ContentUpdatable.needsContentUpdate`.
    var needsContentUpdate = true

    @available(iOS 26.0, *)
    open override func updateProperties() {
        super.updateProperties()
        guard ObservationMode.current == .native else { return }
        updateContent()
    }

    open override func layoutSubviews() {
        runContentUpdateIfNeeded()   // before layout, mirroring UIKit's updateProperties() ordering
        super.layoutSubviews()
    }
}

// MARK: - ContentUpdatable
extension BaseReusableView: ContentUpdatable {}
