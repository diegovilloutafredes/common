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

    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

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
}
