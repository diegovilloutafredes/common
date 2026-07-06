//
//  BaseCollectionViewableViewControllerTests.swift
//

import UIKit
import XCTest
@testable import Common

@MainActor
final class BaseCollectionViewableViewControllerTests: XCTestCase {

    private final class FakeViewModel: CollectionViewDataSourceable, CollectionViewDelegateable, CollectionViewSizeable {
        let itemCount: Int
        init(itemCount: Int) { self.itemCount = itemCount }

        func getNumberOfItems(in section: Int) -> Int { itemCount }
        func onCellForItem(in section: Int, at index: Int) -> ViewModel? { nil }
        func onReuseIdentifierRequested(in section: Int, at index: Int) -> String { .empty }
        func onSizeForItem(in section: Int, at index: Int) -> Size { (.zero, .zero) }
    }

    /// Two sections + recorded selections: the `?? 1` section fallback is
    /// indistinguishable from a one-section view model, and only a spy proves
    /// delegate calls carry the right index path.
    private final class SpyViewModel: CollectionViewDataSourceable, CollectionViewDelegateable, CollectionViewSizeable {
        var selections: [(section: Int, index: Int)] = []

        func getNumberOfSections() -> Int { 2 }
        func getNumberOfItems(in section: Int) -> Int { 3 }
        func onCellForItem(in section: Int, at index: Int) -> ViewModel? { nil }
        func onReuseIdentifierRequested(in section: Int, at index: Int) -> String { .empty }
        func onSizeForItem(in section: Int, at index: Int) -> Size { (width: 10, height: 20) }
        func onItemSelected(in section: Int, at index: Int) { selections.append((section, index)) }
    }

    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let layout = UICollectionViewFlowLayout()

    func test_dataSourceCalls_routeToInjectedViewModel() {
        let vc = BaseCollectionViewableViewController<FakeViewModel>(viewModel: .init(itemCount: 3))
        XCTAssertEqual(vc.collectionView(collectionView, numberOfItemsInSection: 0), 3)
        XCTAssertEqual(vc.numberOfSections(in: collectionView), 1)
    }

    func test_reassigningViewModel_routesDataSourceCallsToNewViewModel() {
        let vc = BaseCollectionViewableViewController<FakeViewModel>(viewModel: .init(itemCount: 3))
        vc.viewModel = .init(itemCount: 7)
        XCTAssertEqual(vc.collectionView(collectionView, numberOfItemsInSection: 0), 7)
    }

    func test_sectionsSelectionAndSizing_routeToViewModel() {
        let viewModel = SpyViewModel()
        let vc = BaseCollectionViewableViewController<SpyViewModel>(viewModel: viewModel)

        XCTAssertEqual(vc.numberOfSections(in: collectionView), 2)

        vc.collectionView(collectionView, didSelectItemAt: IndexPath(item: 1, section: 1))
        XCTAssertEqual(viewModel.selections.count, 1)
        XCTAssertEqual(viewModel.selections.first?.section, 1)
        XCTAssertEqual(viewModel.selections.first?.index, 1)

        let size = vc.collectionView(collectionView, layout: layout, sizeForItemAt: IndexPath(item: 0, section: 0))
        XCTAssertEqual(size, CGSize(width: 10, height: 20))
    }

    /// The generic constraint is intentionally absent (see CLAUDE.md) —
    /// conformance is checked at runtime, so a non-conforming view model must
    /// hit the documented fallbacks, never crash.
    func test_nonConformingViewModel_usesDocumentedFallbacks() {
        final class PlainViewModel {}
        let vc = BaseCollectionViewableViewController<PlainViewModel>(viewModel: PlainViewModel())

        XCTAssertEqual(vc.numberOfSections(in: collectionView), 1)
        XCTAssertEqual(vc.collectionView(collectionView, numberOfItemsInSection: 0), 0)
        XCTAssertEqual(vc.collectionView(collectionView, layout: layout, sizeForItemAt: IndexPath(item: 0, section: 0)), .zero)
    }

    func test_bottomInset_appliesToLastSectionOnly() {
        final class AboveTabBarViewController: BaseCollectionViewableViewController<SpyViewModel> {
            override func bottomInsetForLastCollectionSection() -> CGFloat { 49 }
        }
        let vc = AboveTabBarViewController(viewModel: SpyViewModel())

        let first = vc.collectionView(collectionView, layout: layout, insetForSectionAt: 0)
        let last = vc.collectionView(collectionView, layout: layout, insetForSectionAt: 1)

        XCTAssertEqual(first.bottom, 0, "the extra inset must not leak into earlier sections")
        XCTAssertEqual(last.bottom, 49, "the last section must absorb the tab-bar inset")
    }
}
