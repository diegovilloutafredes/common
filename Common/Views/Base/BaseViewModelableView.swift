//
//  BaseViewModelableView.swift
//

// MARK: - BaseViewModelableView

/// A base view that is driven by a View Model and supports view lifecycle events.
open class BaseViewModelableView<ViewModelType>: ViewModelableView, ViewLifecycleable {
    
    /// The view model associated with this view. Assigning it binds the content synchronously
    /// (`updateContentIfNeeded()`) and arms tracking. On iOS 17–18, an assignment made while another view's or
    /// controller's render is in progress renders in this view's own layout pass instead.
    open var viewModel: ViewModelType {
        didSet {
            setNeedsContentUpdate()
            updateContentIfNeeded()
        }
    }

    /// Initializes a new view with the given view model and binds it, as assigning `viewModel` does, so a view measured
    /// or captured right after initialization shows its content. The binding runs before the body of a subclass's own
    /// initializer, after its stored properties are set.
    /// - Parameter viewModel: The view model to inject.
    required public init(viewModel: ViewModelType) {
        self.viewModel = viewModel
        super.init()
        updateContentIfNeeded()
    }
}
