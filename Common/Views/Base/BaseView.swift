//
//  BaseView.swift
//

import UIKit

// MARK: - BaseView

/// A base view class that conforms to `UIViewBuildable`.
/// It provides a consistent setup for hosting a main view within the view.
open class BaseView: UIView, UIViewBuildable {
    
    /// The main view of the component.
    /// Subclasses should override this to provide their custom view hierarchy.
    /// By default, returns an empty `UIView`.
    @UIViewBuilder open var mainView: UIView { UIView() }

    /// Initializes a new view.
    public init() {
        super.init(frame: .zero)
        setup()
    }

    /// Initializes a new view with the specified frame.
    /// - Parameter frame: The frame rectangle for the view.
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    private func setup() {
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
    /// Default implementation sets the background color to clear.
    open func setupView() { backgroundColor(.clear) }

    /// Pushes state into subviews. Override to read your model here.
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
