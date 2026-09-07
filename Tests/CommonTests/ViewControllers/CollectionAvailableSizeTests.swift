//
//  CollectionAvailableSizeTests.swift
//

import UIKit
import XCTest
@testable import Common

/// The base collection controller hands the view model the size items may occupy, so no view
/// model reads a width through a view reference. Exactly one sizing hook is implemented per
/// view model; the defaults bridge the other.
@MainActor
final class CollectionAvailableSizeTests: XCTestCase {

    /// Sizes through `availableSize` only; records what it was given.
    private final class AvailableSizeViewModel: CollectionViewDataSourceable, CollectionViewDelegateable, CollectionViewSizeable {
        var received: [Size] = []
        var sectionInset: Inset = (.zero, .zero, .zero, .zero)

        func getNumberOfItems(in section: Int) -> Int { 1 }
        func onCellForItem(in section: Int, at index: Int) -> ViewModel? { nil }
        func onReuseIdentifierRequested(in section: Int, at index: Int) -> String { .empty }
        func onInsetFor(section: Int) -> Inset { sectionInset }
        func onSizeForItem(in section: Int, at index: Int, availableSize: Size) -> Size {
            received.append(availableSize)
            return (availableSize.width, 44)
        }
        func onSizeForHeaderItem(in section: Int, availableSize: Size) -> Size { (availableSize.width, 36) }
        func onSizeForFooterItem(in section: Int, availableSize: Size) -> Size { (availableSize.width, 32) }
    }

    /// A pre-existing conformer: implements only the legacy hook.
    private final class LegacyViewModel: CollectionViewDataSourceable, CollectionViewDelegateable, CollectionViewSizeable {
        func getNumberOfItems(in section: Int) -> Int { 1 }
        func onCellForItem(in section: Int, at index: Int) -> ViewModel? { nil }
        func onReuseIdentifierRequested(in section: Int, at index: Int) -> String { .empty }
        func onSizeForItem(in section: Int, at index: Int) -> Size { (100, 50) }
    }

    /// Implements neither hook.
    private final class UnsizedViewModel: CollectionViewDataSourceable, CollectionViewDelegateable, CollectionViewSizeable {
        func getNumberOfItems(in section: Int) -> Int { 1 }
        func onCellForItem(in section: Int, at index: Int) -> ViewModel? { nil }
        func onReuseIdentifierRequested(in section: Int, at index: Int) -> String { .empty }
    }

    private let layout = UICollectionViewFlowLayout()
    private let firstItem = IndexPath(item: 0, section: 0)

    private func collectionView(width: CGFloat, height: CGFloat) -> UICollectionView {
        .init(frame: .init(x: 0, y: 0, width: width, height: height), collectionViewLayout: UICollectionViewFlowLayout())
    }

    func test_verticalListInsideCardMargins_receivesWidthMinusSectionInsets() {
        let viewModel = AvailableSizeViewModel()
        viewModel.sectionInset = (top: 0, left: 8, bottom: 0, right: 8)
        let vc = BaseCollectionViewableViewController<AvailableSizeViewModel>(viewModel: viewModel)

        let size = vc.collectionView(collectionView(width: 343, height: 600), layout: layout, sizeForItemAt: firstItem)

        XCTAssertEqual(viewModel.received.first?.width, 327)
        XCTAssertEqual(size, CGSize(width: 327, height: 44))
    }

    func test_horizontalList_receivesItsHeight() {
        let viewModel = AvailableSizeViewModel()
        let vc = BaseCollectionViewableViewController<AvailableSizeViewModel>(viewModel: viewModel)

        _ = vc.collectionView(collectionView(width: 390, height: 200), layout: layout, sizeForItemAt: firstItem)

        XCTAssertEqual(viewModel.received.first?.height, 200)
    }

    func test_availableSize_subtractsAdjustedContentInsetAndLastSectionBottomInset() {
        final class AboveTabBarViewController: BaseCollectionViewableViewController<AvailableSizeViewModel> {
            override func bottomInsetForLastCollectionSection() -> CGFloat { 49 }
        }
        let viewModel = AvailableSizeViewModel()
        let vc = AboveTabBarViewController(viewModel: viewModel)
        let list = collectionView(width: 390, height: 600)
        list.contentInsetAdjustmentBehavior = .never
        list.contentInset = .init(top: 10, left: 5, bottom: 10, right: 5)

        _ = vc.collectionView(list, layout: layout, sizeForItemAt: firstItem)

        XCTAssertEqual(viewModel.received.first?.width, 380)
        XCTAssertEqual(viewModel.received.first?.height, 600 - 10 - 10 - 49)
    }

    func test_availableSize_neverGoesNegative() {
        let viewModel = AvailableSizeViewModel()
        viewModel.sectionInset = (top: 0, left: 100, bottom: 0, right: 100)
        let vc = BaseCollectionViewableViewController<AvailableSizeViewModel>(viewModel: viewModel)

        _ = vc.collectionView(collectionView(width: 50, height: 0), layout: layout, sizeForItemAt: firstItem)

        XCTAssertEqual(viewModel.received.first?.width, .zero)
        XCTAssertEqual(viewModel.received.first?.height, .zero)
    }

    func test_headerAndFooter_receiveTheAvailableSizeToo() {
        let viewModel = AvailableSizeViewModel()
        viewModel.sectionInset = (top: 0, left: 8, bottom: 0, right: 8)
        let vc = BaseCollectionViewableViewController<AvailableSizeViewModel>(viewModel: viewModel)
        let list = collectionView(width: 343, height: 600)

        XCTAssertEqual(vc.collectionView(list, layout: layout, referenceSizeForHeaderInSection: 0), CGSize(width: 327, height: 36))
        XCTAssertEqual(vc.collectionView(list, layout: layout, referenceSizeForFooterInSection: 0), CGSize(width: 327, height: 32))
    }

    func test_legacyConformer_keepsItsSize() {
        let vc = BaseCollectionViewableViewController<LegacyViewModel>(viewModel: .init())

        let size = vc.collectionView(collectionView(width: 343, height: 600), layout: layout, sizeForItemAt: firstItem)

        XCTAssertEqual(size, CGSize(width: 100, height: 50))
    }

    func test_conformerWithNeitherHook_rendersZero() {
        let vc = BaseCollectionViewableViewController<UnsizedViewModel>(viewModel: .init())

        let size = vc.collectionView(collectionView(width: 343, height: 600), layout: layout, sizeForItemAt: firstItem)

        XCTAssertEqual(size, .zero)
    }
}
