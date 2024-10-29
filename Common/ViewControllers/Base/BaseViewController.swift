//
//  BaseViewController.swift
//

import UIKit

// MARK: - BaseViewController
open class BaseViewController: UIViewController, UIViewBuildable {
    @UIViewBuilder open var mainView: UIView { UIView() }

    public override func loadView() {
        self.view = mainView
    }

    open func setupView() { backgroundColor() }
}

// MARK: - Default preferredStatusBarStyle
extension BaseViewController {
    open override var preferredStatusBarStyle: UIStatusBarStyle { .darkContent }
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

// MARK: - UIGestureRecognizerDelegate
extension BaseViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool { true }
}
