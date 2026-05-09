//
//  BaseViewModelableViewController.swift
//

import UIKit

// MARK: - BaseViewModelableViewController

/// A base view controller that is driven by a View Model.
/// It conforms to `ViewModelableViewController` and `ContentReloadable`.
/// View controllers that own a collection view should subclass
/// `BaseCollectionViewableViewController` instead.
open class BaseViewModelableViewController<ViewModelType>: ViewModelableViewController, ContentReloadable {

    /// The view model associated with this view controller.
    open var viewModel: ViewModelType {
        didSet { cacheViewModelRoles() }
    }

    private var _asViewLifecycleable: ViewLifecycleable?
    private var _asReloadContentRequestable: ReloadContentRequestable?

    private func cacheViewModelRoles() {
        _asViewLifecycleable = viewModel as? ViewLifecycleable
        _asReloadContentRequestable = viewModel as? ReloadContentRequestable
    }

    /// Initializes a new view controller with the given view model.
    /// - Parameter viewModel: The view model to inject.
    required public init(viewModel: ViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        cacheViewModelRoles()
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("NSCoder is not supported")
    }

    // MARK: - View Lifecycle
    open override func viewDidLoad() {
        super.viewDidLoad()
        _asViewLifecycleable?.onViewDidLoad()
    }

    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        _asViewLifecycleable?.onViewWillLayoutSubviews()
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _asViewLifecycleable?.onViewDidLayoutSubviews()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _asViewLifecycleable?.onViewWillAppear()
    }

    open override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        _asViewLifecycleable?.onViewIsAppearing()
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _asViewLifecycleable?.onViewDidAppear()
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _asViewLifecycleable?.onViewWillDisappear()
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        _asViewLifecycleable?.onViewDidDisappear()
    }

    // MARK: - ContentReloadable
    open func reloadContent() {
        Logger.log(self)
        _asReloadContentRequestable?.onReloadContentRequested()
    }
}
