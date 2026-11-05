//
//  BaseViewController.swift
//

import UIKit

// MARK: - BaseViewController

/// A base view controller that conforms to `UIViewBuildable`.
/// It automatically sets the `mainView` as the view controller's view in `loadView`.
open class BaseViewController: UIViewController, UIViewBuildable {
    
    /// The main view of the controller.
    /// Subclasses should override this to provide their custom view hierarchy.
    /// By default, returns an empty `UIView`.
    @UIViewBuilder
    open var mainView: UIView { UIView() }

    open override func loadView() {
        let container = UIView()
        container.addSubview(mainView)
        self.view = container
    }

    /// Configures the view.
    /// Default implementation sets the background color.
    open func setupView() { backgroundColor() }

    /// Pushes state into views. Override to read your model here.
    ///
    /// On iOS 26 UIKit calls this from `updateProperties()` and re-runs it when any
    /// `@Observable` property read inside changes. On iOS 17–18 Common calls it from
    /// `viewWillLayoutSubviews()` under `withObservationTracking` and
    /// re-runs it the same way, except that a trait change re-runs it only for a trait the class declares in
    /// `contentUpdateTraits`.
    /// Do not call it directly; call `setNeedsContentUpdate()`.
    open func updateContent() {}

    /// The traits `updateContent()` reads, declared so that a change to one of them re-runs the hook on iOS 17 and 18.
    ///
    /// The native mode (iOS 26) re-runs a hook whose traits changed by itself. The manual mode (iOS 17–18) doesn't: there
    /// the controller registers these traits in `viewDidLoad()`, right after `setupView()`, and schedules
    /// `updateContent()` when one changes. Declare the interface style for a hook that sets a layer color through
    /// `cgColor` (as `borderColor(_:)` does) or reads `traitCollection`:
    ///
    /// ```swift
    /// override class var contentUpdateTraits: [UITrait] { [UITraitUserInterfaceStyle.self] }
    /// ```
    ///
    /// Empty by default, so nothing is registered. A declared trait costs one more render on first display when the
    /// window's value differs from the one the controller's view was rendered with.
    open class var contentUpdateTraits: [UITrait] { [] }

    /// Schedules `updateContent()` for the next update pass.
    /// A no-op before the view loads: the first update pass runs the hook anyway, and
    /// touching `view` here would force `loadView()` early.
    public func setNeedsContentUpdate() {
        guard isViewLoaded else { return }
        if #available(iOS 26.0, *), ObservationMode.current == .native {
            setNeedsUpdateProperties()
        } else {
            needsContentUpdate = true
            view.setNeedsLayout()
        }
    }

    /// Runs a pending `updateContent()` now instead of waiting for the next update pass, for a controller that needs a
    /// synchronous render, before a snapshot or a custom transition.
    ///
    /// Does nothing before the view loads, and doesn't load it, and nothing when no update is pending. On iOS 17–18,
    /// while another view's or controller's render is in progress, the update stays scheduled for this controller's own
    /// pass instead, so its reads don't join that render's tracking.
    public func updateContentIfNeeded() {
        guard isViewLoaded else { return }
        if #available(iOS 26.0, *), ObservationMode.current == .native {
            updatePropertiesIfNeeded()
        } else {
            guard !ObservationTracker.isRendering else { return }
            runContentUpdateIfNeeded()
        }
    }

    /// Manual/unavailable-mode bookkeeping: `true` until the first pass, then only after an
    /// invalidation, so unrelated layout passes skip the hook.
    private var needsContentUpdate = true

    /// The controller's manual-mode registration (see `ContentTracking`).
    private lazy var contentTracking = ContentTracking()

    /// Registers `contentUpdateTraits` in the manual mode, where a trait change doesn't re-run `updateContent()` by itself.
    /// Nothing in the native mode, where UIKit already re-runs a hook whose traits changed.
    fileprivate func registerContentUpdateTraits() {
        let traits = Self.contentUpdateTraits
        guard traits.isNotEmpty, ObservationMode.current == .manual else { return }
        registerForTraitChanges(traits) { (self: BaseViewController, _: UITraitCollection) in self.setNeedsContentUpdate() }
    }

    fileprivate func runContentUpdateIfNeeded() {
        let mode = ObservationMode.current
        guard mode != .native else { return }
        guard mode == .unavailable || needsContentUpdate else { return }
        needsContentUpdate = false
        contentTracking.run { updateContent() } onInvalidate: { [weak self] in self?.setNeedsContentUpdate() }
    }

    @available(iOS 26.0, *)
    open override func updateProperties() {
        super.updateProperties()
        guard ObservationMode.current == .native else { return }
        updateContent()
    }
}

// MARK: - Default preferredStatusBarStyle
extension BaseViewController {
    open override var preferredStatusBarStyle: UIStatusBarStyle { .darkContent }
}

// MARK: - Default prefersHomeIndicatorAutoHidden
extension BaseViewController {
    open override var prefersHomeIndicatorAutoHidden: Bool { true }
}

// MARK: - Lifecycle
extension BaseViewController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        Logger.log(["From": Self.self])
        setupView()
        registerContentUpdateTraits()
    }

    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        runContentUpdateIfNeeded()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        defer { Logger.log(["From": Self.self]) }
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    /// Called after viewWillAppear but before viewDidAppear. The key difference is that it’s called after the view has been added to the hierarchy but is not yet onscreen.
    /// The view controller’s view has been laid out so you can rely on its size and traits.
    open override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        Logger.log(["From": Self.self])
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Logger.log(["From": Self.self])
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Logger.log(["From": Self.self])
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Logger.log(["From": Self.self])
    }
}

/// Restores the swipe to go back gesture when using a custom back button.
// MARK: - UIGestureRecognizerDelegate
extension BaseViewController: UIGestureRecognizerDelegate {
    /// Lets the navigation controller's swipe-back gesture begin only when there is a screen to go back to. Any other
    /// recognizer this controller is the delegate of begins normally. Override it to block swipe-back on a screen, for
    /// example while a payment is in progress.
    @objc open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === navigationController?.interactivePopGestureRecognizer else { return true }
        return navigationController?.viewControllers.count ?? .zero > 1
    }
}
