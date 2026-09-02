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
            setNeedsLayout()
        }
    }

    @available(iOS 26.0, *)
    open override func updateProperties() {
        super.updateProperties()
        guard ObservationMode.current == .native else { return }
        updateContent()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        guard ObservationMode.current != .native else { return }
        ObservationTracker.run { updateContent() } onInvalidate: { [weak self] in self?.setNeedsLayout() }
    }
}
