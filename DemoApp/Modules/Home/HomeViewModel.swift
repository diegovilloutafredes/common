//
//  HomeViewModel.swift
//  DemoApp
//

import Common

// MARK: - HomeViewModelProtocol
protocol HomeViewModelProtocol: CollectionViewable, ViewModel {
    var title: String { get }
}

// MARK: - HomeViewModel
@MainActor
final class HomeViewModel {
    /// One case per destination; `AppCoordinator` answers each with navigation.
    enum Requested {
        case declarativeUI, networking, storage, alerts, localAuth, extensions, onboarding, forms
        case lists, utilities, camera, coordinatorDemo, imageLoading, typography, components, observation
    }

    let title = "Common Demo"
    private let onRequested: Handler<Requested>

    private lazy var dataSource: [DemoFeatureCellViewModelImpl] = [
        .init(
            title: "Declarative UI",
            subtitle: "@UIViewBuilder, VStack, HStack",
            action: { [weak self] in self?.onRequested(.declarativeUI) }
        ),
        .init(
            title: "Networking",
            subtitle: "BaseClient + JSONPlaceholder",
            action: { [weak self] in self?.onRequested(.networking) }
        ),
        .init(
            title: "Storage",
            subtitle: "UserDefaults, FileStorage, Keychain",
            action: { [weak self] in self?.onRequested(.storage) }
        ),
        .init(
            title: "Alerts & Feedback",
            subtitle: "Snackbar, Toast, Alert, ActivityIndicator",
            action: { [weak self] in self?.onRequested(.alerts) }
        ),
        .init(
            title: "Auth",
            subtitle: "FaceID / TouchID / Apple Sign-In",
            action: { [weak self] in self?.onRequested(.localAuth) }
        ),
        .init(
            title: "Extensions",
            subtitle: "UIView, UILabel, UIColor extensions",
            action: { [weak self] in self?.onRequested(.extensions) }
        ),
        .init(
            title: "Onboarding",
            subtitle: "Paged HList, page control, dynamic button",
            action: { [weak self] in self?.onRequested(.onboarding) }
        ),
        .init(
            title: "Forms & TextFields",
            subtitle: "Validation, keyboard layout, secure entry",
            action: { [weak self] in self?.onRequested(.forms) }
        ),
        .init(
            title: "Lists & Cells",
            subtitle: "VList, BaseViewModelableCell, pull-to-refresh",
            action: { [weak self] in self?.onRequested(.lists) }
        ),
        .init(
            title: "Utilities",
            subtitle: "Debouncer, UIDatePicker, CircularActivityIndicator",
            action: { [weak self] in self?.onRequested(.utilities) }
        ),
        .init(
            title: "Camera",
            subtitle: "CameraManager, PreviewView, authorization flow",
            action: { [weak self] in self?.onRequested(.camera) }
        ),
        .init(
            title: "Coordinator",
            subtitle: "Child lifecycle, auto-cancel, sheets, pop-to cascade",
            action: { [weak self] in self?.onRequested(.coordinatorDemo) }
        ),
        .init(
            title: "Image Loading",
            subtitle: "loadImage(from:), two-tier cache, cell reuse cancellation",
            action: { [weak self] in self?.onRequested(.imageLoading) }
        ),
        .init(
            title: "Typography",
            subtitle: "AppFontFamily, FontStyle, PostScript derivation",
            action: { [weak self] in self?.onRequested(.typography) }
        ),
        .init(
            title: "Components",
            subtitle: "GradientView, PillUILabel, ProgressAnimationView",
            action: { [weak self] in self?.onRequested(.components) }
        ),
        .init(
            title: "Observation",
            subtitle: "@Observable models, updateContent(), ViewEvent",
            action: { [weak self] in self?.onRequested(.observation) }
        ),
    ]

    init(onRequested: @escaping Handler<Requested>) {
        self.onRequested = onRequested
    }
}

// MARK: - CollectionViewable
extension HomeViewModel: CollectionViewable {
    func getNumberOfItems(in section: Int) -> Int { dataSource.count }
    func onCellForItem(in section: Int, at index: Int) -> ViewModel? { dataSource[index] }
    func onReuseIdentifierRequested(in section: Int, at index: Int) -> String { DemoFeatureCell.reuseIdentifier }
    func onSizeForItem(in section: Int, at index: Int, availableSize: Size) -> Size {
        (availableSize.width, 96)
    }
    func onItemSelected(in section: Int, at index: Int) { dataSource[index].action() }
}

// MARK: - HomeViewModelProtocol
extension HomeViewModel: HomeViewModelProtocol {}
