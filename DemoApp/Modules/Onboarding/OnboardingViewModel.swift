//
//  OnboardingViewModel.swift
//

import Common
import Observation

// MARK: - ViewModel
@MainActor
protocol OnboardingViewModelProtocol: CollectionViewable, ViewLifecycleable {
    var onRequested: Handler<OnboardingViewModel.OnRequested> { get }
    var currentPage: Int { get }
    var pageCount: Int { get }
    var isLastPage: Bool { get }
    var buttonTitle: String { get }
    /// The "Saltar" bar item is shown on every page but the last.
    var showsSkip: Bool { get }
    /// Called by the pager as the user scrolls; same-value writes are ignored.
    func set(currentPage: Int)
    /// The primary button: next page, or `.begin` on the last one.
    func advance()
}

// MARK: - OnboardingViewModel
@Observable
@MainActor
final class OnboardingViewModel {
    enum OnRequested {
        case skip
        case begin
    }

    @ObservationIgnored internal let onRequested: Handler<OnRequested>
    @ObservationIgnored weak var view: OnboardingViewProtocol?
    @ObservationIgnored private let dataSource: [OnboardingCellViewModel] = (0...2).map { OnboardingStep(rawValue: $0) ?? .first }

    private(set) var currentPage: Int = .zero

    init(onRequested: @escaping Handler<OnRequested>) {
        self.onRequested = onRequested
    }

    var pageCount: Int { dataSource.count }
    var isLastPage: Bool { currentPage >= pageCount - 1 }
    var buttonTitle: String { isLastPage ? "Comenzar" : "Siguiente" }
    var showsSkip: Bool { !isLastPage }
}

// MARK: - OnboardingViewModelProtocol
extension OnboardingViewModel: OnboardingViewModelProtocol {
    func set(currentPage: Int) {
        let clamped = min(max(currentPage, .zero), pageCount - 1)
        guard clamped != self.currentPage else { return }
        self.currentPage = clamped
    }

    func advance() {
        guard !isLastPage else { onRequested(.begin); return }
        currentPage += 1
    }
}

// MARK: - CollectionViewable
extension OnboardingViewModel: CollectionViewable {
    func getNumberOfItems(in section: Int) -> Int { dataSource.count }
    func onCellForItem(in section: Int, at index: Int) -> ViewModel? { dataSource[index] }
    func onReuseIdentifierRequested(in section: Int, at index: Int) -> String { OnboardingCell.reuseIdentifier }
    func onSizeForItem(in section: Int, at index: Int) -> (width: Double, height: Double) { (view?.screenWidth ?? .zero, (view?.screenHeight ?? .zero) * 0.75) }
}
