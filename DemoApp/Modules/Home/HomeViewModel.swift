//
//  HomeViewModel.swift
//  DemoApp
//

import Common

// MARK: - DemoFeature
struct DemoFeature {
    let title: String
    let subtitle: String
    let action: () -> Void
}

// MARK: - HomeViewModelProtocol
protocol HomeViewModelProtocol: ViewModel, CollectionViewable {
    var title: String { get }
}

// MARK: - HomeViewModel
final class HomeViewModel {
    let title = "Common Demo"
    weak var coordinator: AppCoordinator?

    private lazy var dataSource: [DemoFeatureCellViewModelImpl] = [
        .init(
            title: "Declarative UI",
            subtitle: "@UIViewBuilder, VStack, HStack",
            action: { [weak self] in self?.coordinator?.showDeclarativeUI() }
        ),
        .init(
            title: "Networking",
            subtitle: "BaseClient + JSONPlaceholder",
            action: { [weak self] in self?.coordinator?.showNetworking() }
        ),
        .init(
            title: "Storage",
            subtitle: "UserDefaults, FileStorage, Keychain",
            action: { [weak self] in self?.coordinator?.showStorage() }
        ),
        .init(
            title: "Alerts & Feedback",
            subtitle: "Snackbar, Toast, Alert, ActivityIndicator",
            action: { [weak self] in self?.coordinator?.showAlerts() }
        ),
        .init(
            title: "Local Authentication",
            subtitle: "FaceID / TouchID / Passcode",
            action: { [weak self] in self?.coordinator?.showLocalAuth() }
        ),
        .init(
            title: "Extensions",
            subtitle: "UIView, UILabel, UIColor extensions",
            action: { [weak self] in self?.coordinator?.showExtensions() }
        ),
    ]

    weak var view: HomeViewProtocol?

    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
    }
}

// MARK: - CollectionViewable
extension HomeViewModel: CollectionViewable {
    func getNumberOfItems(in section: Int) -> Int { dataSource.count }
    func onCellForItem(in section: Int, at index: Int) -> ViewModel? { dataSource[index] }
    func onReuseIdentifierRequested(in section: Int, at index: Int) -> String { DemoFeatureCell.reuseIdentifier }
    func onSizeForItem(in section: Int, at index: Int) -> (width: Double, height: Double) {
        (view?.screenWidth ?? 375, 72)
    }
    func onItemSelected(in section: Int, at index: Int) { dataSource[index].action() }
}

// MARK: - HomeViewModelProtocol
extension HomeViewModel: HomeViewModelProtocol {}
