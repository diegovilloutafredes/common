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
        func onSizeForFooterItem(in section: Int) -> Size { section == 1 ? (width: 30, height: 40) : (.zero, .zero) }
        func onItemSelected(in section: Int, at index: Int) { selections.append((section, index)) }
    }

    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let layout = UICollectionViewFlowLayout()

    // MARK: - Binding the data source's model, nil included

    private final class Item: ViewModel {
        let text: String
        init(_ text: String) { self.text = text }
    }

    private final class CountingCell: BaseViewModelableCell<Item> {
        static let identifier = "CountingCell"
        var updates = 0
        override func updateContent() { updates += 1 }
    }

    private final class CountingHeader: BaseViewModelableReusableView<Item> {
        static let identifier = "CountingHeader"
        var updates = 0
        override func updateContent() { updates += 1 }
    }

    /// One item with a header; `hasModels = false` makes the data source return nil for both.
    private final class SwitchableViewModel: CollectionViewDataSourceable, CollectionViewDelegateable, CollectionViewSizeable {
        var hasModels = true
        func getNumberOfItems(in section: Int) -> Int { 1 }
        func onCellForItem(in section: Int, at index: Int) -> ViewModel? { hasModels ? Item("item") : nil }
        func onReuseIdentifierRequested(in section: Int, at index: Int) -> String { CountingCell.identifier }
        func onSizeForItem(in section: Int, at index: Int) -> Size { (width: 100, height: 44) }
        func onHeaderItemDataSourceRequested(in section: Int) -> ViewModel? { hasModels ? Item("header") : nil }
        func onHeaderItemReuseIdentifierRequested(in section: Int) -> String { CountingHeader.identifier }
        func onSizeForHeaderItem(in section: Int) -> Size { (width: 100, height: 30) }
    }

    /// The defect: when the data source returned nil, the base skipped the assignment, so a recycled cell or header
    /// kept the model, and the content, of the item it showed before.
    func test_nilModel_isAssignedToTheRecycledCellAndHeader() throws {
        let window = UIWindow(frame: .init(x: 0, y: 0, width: 320, height: 640))
        window.isHidden = false
        defer { window.isHidden = true }
        let viewModel = SwitchableViewModel()
        let vc = BaseCollectionViewableViewController<SwitchableViewModel>(viewModel: viewModel)
        let list = UICollectionView(frame: window.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        list.register(CountingCell.self, forCellWithReuseIdentifier: CountingCell.identifier)
        list.register(CountingHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CountingHeader.identifier)
        list.dataSource = vc
        list.delegate = vc
        window.addSubview(list)
        list.reloadData()
        list.layoutIfNeeded()

        let first = IndexPath(item: 0, section: 0)
        let cell = try XCTUnwrap(list.cellForItem(at: first) as? CountingCell)
        let header = try XCTUnwrap(list.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: first) as? CountingHeader)
        XCTAssertEqual(cell.viewModel?.text, "item")
        XCTAssertEqual(header.viewModel?.text, "header")
        let cellUpdates = cell.updates, headerUpdates = header.updates

        viewModel.hasModels = false
        list.reloadData()
        list.layoutIfNeeded()

        let recycledCell = try XCTUnwrap(list.cellForItem(at: first) as? CountingCell)
        let recycledHeader = try XCTUnwrap(list.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: first) as? CountingHeader)
        XCTAssertIdentical(recycledCell, cell, "precondition: the cell must be recycled")
        XCTAssertIdentical(recycledHeader, header, "precondition: the header must be recycled")
        XCTAssertNil(recycledCell.viewModel)
        XCTAssertNil(recycledHeader.viewModel)
        XCTAssertGreaterThan(recycledCell.updates, cellUpdates, "updateContent() must run for the nil model")
        XCTAssertGreaterThan(recycledHeader.updates, headerUpdates, "updateContent() must run for the nil model")
    }

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

        // Footer sizing routes per section; the unimplemented-section default is zero,
        // so no footer is dequeued where the view model declines one.
        XCTAssertEqual(vc.collectionView(collectionView, layout: layout, referenceSizeForFooterInSection: 1), CGSize(width: 30, height: 40))
        XCTAssertEqual(vc.collectionView(collectionView, layout: layout, referenceSizeForFooterInSection: 0), .zero)
    }

    /// The generic constraint is intentionally absent (guide §5, `BaseCollectionViewableViewController`):
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

    func test_scrollViewWillEndDragging_overrideIsReachableViaSelectorDispatch() {
        final class SnappingViewController: BaseCollectionViewableViewController<SpyViewModel> {
            var didSnap = false
            override func scrollViewWillEndDragging(
                _ scrollView: UIScrollView,
                withVelocity velocity: CGPoint,
                targetContentOffset: UnsafeMutablePointer<CGPoint>
            ) {
                didSnap = true
            }
        }
        let vc = SnappingViewController(viewModel: SpyViewModel())
        let delegate: UIScrollViewDelegate = vc
        var offset = CGPoint.zero
        withUnsafeMutablePointer(to: &offset) {
            delegate.scrollViewWillEndDragging?(collectionView, withVelocity: .zero, targetContentOffset: $0)
        }
        XCTAssertTrue(vc.didSnap, "a subclass override must be reachable through ObjC selector dispatch")
    }
}
