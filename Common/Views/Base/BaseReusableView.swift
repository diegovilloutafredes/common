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

    override public init(frame: CGRect) {
        super.init(frame: frame)
        subviews { mainView.setConstraints { $0.snap(to: $1) } }
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
    public func setNeedsContentUpdate() {
        if #available(iOS 26.0, *), ObservationMode.current == .native {
            setNeedsUpdateProperties()
        } else {
            needsContentUpdate = true
            setNeedsLayout()
        }
    }

    /// Runs a pending `updateContent()` now instead of waiting for the next update pass.
    ///
    /// The view-model-able subclasses call this right after `viewModel` is assigned: self-sizing
    /// cells are measured immediately after configuration, before any layout or properties pass,
    /// so the content has to be bound synchronously. Tracking is armed by that run, and later
    /// observable changes are still delivered on the next pass.
    public func updateContentIfNeeded() {
        if #available(iOS 26.0, *), ObservationMode.current == .native {
            updatePropertiesIfNeeded()
        } else {
            runContentUpdateIfNeeded()
        }
    }

    /// Manual/unavailable-mode bookkeeping: `true` until the first pass, then only after an
    /// invalidation, so unrelated layout passes (scrolling, rotation) skip the hook.
    private var needsContentUpdate = true

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

    private func runContentUpdateIfNeeded() {
        let mode = ObservationMode.current
        guard mode != .native else { return }
        guard mode == .unavailable || needsContentUpdate else { return }
        needsContentUpdate = false
        ObservationTracker.run { updateContent() } onInvalidate: { [weak self] in self?.setNeedsContentUpdate() }
    }
}
