//
//  BaseViewModelable.swift
//

// MARK: - BaseViewModelable
open class BaseViewModelableView<ViewModelType>: ViewModelableView, ViewLifecycleable {
    public func set(viewModel: any ViewModel) {
        
    }
    
    open var viewModel: ViewModelType

    required public init(viewModel: ViewModelType) {
        self.viewModel = viewModel
        super.init()
    }
}
