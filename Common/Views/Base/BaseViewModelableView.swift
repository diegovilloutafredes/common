//
//  BaseViewModelableView.swift
//

// MARK: - BaseViewModelableView

/// A base view that is driven by a View Model and supports view lifecycle events.
open class BaseViewModelableView<ViewModelType>: ViewModelableView, ViewLifecycleable {
    
    /// The view model associated with this view. Assigning it schedules `updateContent()`.
    open var viewModel: ViewModelType {
        didSet { setNeedsContentUpdate() }
    }

    /// Initializes a new view with the given view model.
    /// - Parameter viewModel: The view model to inject.
    required public init(viewModel: ViewModelType) {
        self.viewModel = viewModel
        super.init()
    }
}
