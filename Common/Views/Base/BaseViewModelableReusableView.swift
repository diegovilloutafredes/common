//
//  BaseViewModelableReusableView.swift
//

// MARK: - BaseViewModelableReusableView

/// A base reusable view that is driven by a View Model.
open class BaseViewModelableReusableView<ViewModelType>: ViewModelableReusableView {
    
    /// The view model associated with this reusable view. Assigning it binds the content
    /// synchronously (`updateContentIfNeeded()`), so self-sizing measurement sees it, and arms tracking.
    open var viewModel: ViewModelType? {
        didSet {
            setNeedsContentUpdate()
            updateContentIfNeeded()
        }
    }
}
