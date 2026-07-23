//
//  ComponentsViewModel.swift
//  DemoApp
//

import Common

// MARK: - ComponentsViewProtocol
protocol ComponentsViewProtocol: BackButtonAddable {}

// MARK: - ComponentsViewModelProtocol
protocol ComponentsViewModelProtocol: ViewModel, ViewLifecycleable {
    var title: String { get }
}

// MARK: - ComponentsViewModel
@MainActor
final class ComponentsViewModel {
    let title = "Components"
    weak var view: ComponentsViewProtocol?
    private let onGoBack: Action

    init(onGoBack: @escaping Action) {
        self.onGoBack = onGoBack
    }
}

// MARK: - ComponentsViewModelProtocol
extension ComponentsViewModel: ComponentsViewModelProtocol {}

// MARK: - ViewLifecycleable
extension ComponentsViewModel: ViewLifecycleable {
    func onViewDidLoad() {
        // BackButtonAddable demo: replace the system back button with Common's,
        // routing the pop through the coordinator instead of popping from the VC.
        view?.addBackButton { [weak self] in self?.onGoBack() }
    }
}
