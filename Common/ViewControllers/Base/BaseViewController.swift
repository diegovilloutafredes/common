//
//  BaseViewController.swift
//

import UIKit

// MARK: - BaseViewController

/// A base view controller that provides common functionality and lifecycle handling.
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
        self.view = mainView
    }

    /// Configures the view.
    /// Default implementation sets the background color.
    open func setupView() { backgroundColor() }
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
    }

    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        Logger.log(["From": Self.self])
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        Logger.log(["From": Self.self])
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
}

/// Restores the swipe to go back gesture when using a custom back button.
// MARK: - UIGestureRecognizerDelegate
extension BaseViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool { navigationController?.viewControllers.count ?? .zero > 1 }
}
