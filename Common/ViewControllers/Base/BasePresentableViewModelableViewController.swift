//
//  BasePresentableViewModelableViewController.swift
//

// MARK: - BasePresentableViewModelableViewController
open class BasePresentableViewModelableViewController<PresenterType, ViewModelType>: BasePresentableViewController<PresenterType>, ViewModelHolder, ViewModelSettable {
    open var viewModel: ViewModelType?
}
