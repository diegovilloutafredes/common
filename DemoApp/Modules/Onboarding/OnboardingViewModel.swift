//
//  OnboardingViewModel.swift
//

import Common
import Observation

// MARK: - ViewModel
@MainActor
protocol OnboardingViewModelProtocol: CollectionViewable, ViewLifecycleable {
    var currentPage: Int { get }
    var pageCount: Int { get }
    var isLastPage: Bool { get }
    var buttonTitle: String { get }
    /// The "Saltar" bar item is shown on every page but the last.
    var showsSkip: Bool { get }
    /// Called by the pager as the user scrolls; same-value writes are ignored.
    func set(currentPage: Int)
    /// The primary button: next page, or the `.begin` result on the last one.
    func advance()
    /// The "Saltar" bar item: abandons the flow.
    func skip()
}

// MARK: - OnboardingViewModel
@Observable
@MainActor
final class OnboardingViewModel {
    /// Navigation the coordinator answers.
    enum Requested { case skip }
    /// Results the coordinator reacts to.
    enum Performed { case begin }

    @ObservationIgnored private let onRequested: Handler<Requested>
    @ObservationIgnored private let onPerformed: Handler<Performed>
    @ObservationIgnored private let dataSource: [OnboardingCellViewModel] = (0...2).map { OnboardingStep(rawValue: $0) ?? .first }

    private(set) var currentPage: Int = .zero

    init(onRequested: @escaping Handler<Requested>, onPerformed: @escaping Handler<Performed>) {
        self.onRequested = onRequested
        self.onPerformed = onPerformed
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
        guard !isLastPage else { onPerformed(.begin); return }
        currentPage += 1
    }

    func skip() { onRequested(.skip) }
}

// MARK: - CollectionViewable
extension OnboardingViewModel: CollectionViewable {
    func getNumberOfItems(in section: Int) -> Int { dataSource.count }
    func onCellForItem(in section: Int, at index: Int) -> ViewModel? { dataSource[index] }
    func onReuseIdentifierRequested(in section: Int, at index: Int) -> String { OnboardingCell.reuseIdentifier }
    /// Paged full-size cards: each item fills the list it is handed.
    func onSizeForItem(in section: Int, at index: Int, availableSize: Size) -> Size { availableSize }
}
