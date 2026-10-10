//
//  BaseViewModelableViewController.swift
//

import UIKit

// MARK: - BaseViewModelableViewController

/// A base view controller that is driven by a View Model.
/// It conforms to `ViewModelableViewController`.
/// View controllers that own a collection view should subclass
/// `BaseCollectionViewableViewController` instead.
open class BaseViewModelableViewController<ViewModelType>: ViewModelableViewController {

    /// The view model associated with this view controller.
    open var viewModel: ViewModelType {
        didSet {
            cacheViewModelRoles()
            setNeedsContentUpdate()
        }
    }

    private var _asViewLifecycleable: ViewLifecycleable?

    private func cacheViewModelRoles() {
        _asViewLifecycleable = viewModel as? ViewLifecycleable
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

    open override func updateContent() {
        super.updateContent()
        _asViewLifecycleable?.onUpdateProperties()
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
    @available(*, deprecated, message: "Call an intent on the view model; the controller re-renders in updateContent() (guide §6).")
    open func reloadContent() {
        Logger.log(self)
        (viewModel as? ReloadContentRequestable)?.onReloadContentRequested()
    }
}

// MARK: - ContentReloadable
@available(*, deprecated, message: "Let the view model reload itself from an intent or a ViewLifecycleable hook; the controller re-renders in updateContent() (guide §6).")
extension BaseViewModelableViewController: ContentReloadable {}
