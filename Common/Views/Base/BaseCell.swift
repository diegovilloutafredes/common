//
//  BaseCell.swift
//

import UIKit

// MARK: - BaseCell

/// A base collection view cell that conforms to `UIViewBuildable`.
/// It provides a consistent setup for hosting a main view within the cell.
open class BaseCell: UICollectionViewCell, UIViewBuildable {
    
    /// The main view of the cell.
    /// Subclasses should override this to provide their custom view hierarchy.
    /// By default, returns an empty `UIView`.
    @UIViewBuilder open var mainView: UIView { UIView() }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        contentView.subviews { mainView.setConstraints { $0.snap(to: $1) } }
        setupCell()
    }

    @available(*, unavailable)
    required public init(coder aDecoder: NSCoder) {
        fatalError("NSCoder is not supported")
    }

    public override class var requiresConstraintBasedLayout: Bool { true }

    /// Sets up the cell after `mainView` is installed.
    /// Override to perform additional configuration (gesture recognizers, data binding, etc.).
    ///
    /// **Retain cycles:** closures stored inside subviews (e.g. `.onTap {}`) must capture `self`
    /// weakly — the subview is owned by the cell's view hierarchy, creating a reference cycle
    /// if `self` is captured strongly.
    open func setupCell() {}

    /// Pushes state into subviews. Override to read `viewModel` (in the view-model-able
    /// subclass) or any `@Observable` model here.
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
extension BaseCell: ContentUpdatable {}
