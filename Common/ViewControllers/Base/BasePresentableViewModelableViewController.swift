//
//  BasePresentableViewModelableViewController.swift
//

// MARK: - BasePresentableViewModelableViewController
open class BasePresentableViewModelableViewController<PresenterType, ViewModelType>: BasePresentableViewController<PresenterType>, ViewModelHolder, ViewModelSettable {
    open var viewModel: ViewModelType?

    public required init(presenter: PresenterType) {
        super.init(presenter: presenter)
    }

    public init(presenter: PresenterType, viewModel: ViewModelType) {
        self.viewModel = viewModel
        super.init(presenter: presenter)
    }
}
