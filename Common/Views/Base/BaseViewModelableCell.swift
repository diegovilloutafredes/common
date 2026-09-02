//
//  BaseViewModelableCell.swift
//

// MARK: - BaseViewModelableCell

/// A base collection view cell that is driven by a View Model.
open class BaseViewModelableCell<ViewModelType>: ViewModelableCell {
    
    /// The view model associated with this cell. Assigning it binds the content synchronously
    /// (`updateContentIfNeeded()`), so self-sizing measurement sees it, and arms tracking.
    open var viewModel: ViewModelType? {
        didSet {
            setNeedsContentUpdate()
            updateContentIfNeeded()
        }
    }
}
