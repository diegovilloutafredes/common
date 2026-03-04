//
//  BaseViewModelableReusableView.swift
//

// MARK: - BaseViewModelableReusableView
// MARK: - BaseViewModelableReusableView

/// A base reusable view that is driven by a View Model.
open class BaseViewModelableReusableView<ViewModelType>: ViewModelableReusableView {
    
    /// The view model associated with this reusable view.
    open var viewModel: ViewModelType?
}
