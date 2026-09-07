//
//  ComponentsViewModel.swift
//  DemoApp
//

import Common

// MARK: - ComponentsViewModelProtocol
protocol ComponentsViewModelProtocol: ViewModel {
    var title: String { get }
    /// The controller's back button calls this; the coordinator answers the request by popping.
    func goBack()
}

// MARK: - ComponentsViewModel
@MainActor
final class ComponentsViewModel {
    enum Requested { case goBack }

    let title = "Components"
    private let onRequested: Handler<Requested>

    init(onRequested: @escaping Handler<Requested>) {
        self.onRequested = onRequested
    }
}

// MARK: - ComponentsViewModelProtocol
extension ComponentsViewModel: ComponentsViewModelProtocol {
    func goBack() { onRequested(.goBack) }
}
