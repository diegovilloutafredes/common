//
//  OnboardingViewModel.swift
//

import Common

// MARK: - ViewModel
protocol OnboardingViewModelProtocol: CollectionViewable, ViewLifecycleable {
    var onRequested: Handler<OnboardingViewModel.OnRequested> { get }
}

// MARK: - OnboardingViewModel
final class OnboardingViewModel {
    enum OnRequested {
        case skip
        case begin
    }

    internal let onRequested: Handler<OnRequested>

    init(onRequested: @escaping Handler<OnRequested>) {
        self.onRequested = onRequested
    }

    weak var view: OnboardingViewProtocol?

    private var dataSource: [OnboardingCellViewModel] = (0...2).map { OnboardingStep(rawValue: $0) ?? .first }
}

// MARK: - CollectionViewable
extension OnboardingViewModel: CollectionViewable {
    func getNumberOfItems(in section: Int) -> Int { dataSource.count }
    func onCellForItem(in section: Int, at index: Int) -> ViewModel? { dataSource[index] }
    func onReuseIdentifierRequested(in section: Int, at index: Int) -> String { OnboardingCell.reuseIdentifier }
    func onSizeForItem(in section: Int, at index: Int) -> (width: Double, height: Double) { (view?.screenWidth ?? .zero, (view?.screenHeight ?? .zero) * 0.75) }
}

// MARK: - OnboardingViewModelProtocol
extension OnboardingViewModel: OnboardingViewModelProtocol {}
