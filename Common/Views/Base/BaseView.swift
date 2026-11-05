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
        registerContentUpdateTraits(Self.contentUpdateTraits)
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
    /// `layoutSubviews()` under `withObservationTracking` and re-runs it the same way, with two differences: a trait
    /// change re-runs it only for a trait the class declares in `contentUpdateTraits`, and a view bound while another
    /// render is in progress renders in its own layout pass instead of inside that render.
    /// Do not call it directly; call `setNeedsContentUpdate()`.
    open func updateContent() {}

    /// The traits `updateContent()` reads, declared so that a change to one of them re-runs the hook on iOS 17 and 18.
    ///
    /// The native mode (iOS 26) re-runs a hook whose traits changed by itself. The manual mode (iOS 17–18) doesn't: there
    /// the view registers these traits right after `setupView()` and schedules `updateContent()` when one changes.
    /// Declare the interface style for a hook that sets a layer color through `cgColor` (as `borderColor(_:)` does) or
    /// reads `traitCollection`:
    ///
    /// ```swift
    /// override class var contentUpdateTraits: [UITrait] { [UITraitUserInterfaceStyle.self] }
    /// ```
    ///
    /// Empty by default, so nothing is registered. A declared trait costs one more render on first display when the
    /// window's value differs from the one the view was bound with (a dark window on a device in light mode).
    open class var contentUpdateTraits: [UITrait] { [] }

    /// Schedules `updateContent()` for the next update pass.
    public func setNeedsContentUpdate() { scheduleContentUpdate() }

    /// Runs a pending `updateContent()` now instead of waiting for the next update pass.
    ///
    /// The view-model-able subclasses call this right after `viewModel` is assigned: self-sizing
    /// cells are measured immediately after configuration, before any layout or properties pass,
    /// so the content has to be bound synchronously. Tracking is armed by that run, and later
    /// observable changes are still delivered on the next pass.
    ///
    /// On iOS 17–18, while another view's or controller's render is in progress, the update stays scheduled for this
    /// view's own layout pass instead, so its reads don't join that render's tracking.
    public func updateContentIfNeeded() { flushContentUpdateIfNeeded() }

    /// See `ContentUpdatable.needsContentUpdate`.
    var needsContentUpdate = true

    /// See `ContentUpdatable.contentTracking`.
    lazy var contentTracking = ContentTracking()

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
extension BaseView: ContentUpdatable {}
