//
//  BaseViewModelableCell.swift
//

// MARK: - BaseViewModelableCell
// MARK: - BaseViewModelableCell

/// A base collection view cell that is driven by a View Model.
open class BaseViewModelableCell<ViewModelType>: ViewModelableCell {
    
    /// The view model associated with this cell.
    open var viewModel: ViewModelType?
}
