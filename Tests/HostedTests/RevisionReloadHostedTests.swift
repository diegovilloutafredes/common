//
//  RevisionReloadHostedTests.swift
//

import Observation
import UIKit
import XCTest
import Common

@Observable
private final class ItemsViewModel: CollectionViewDataSourceable, CollectionViewDelegateable, CollectionViewSizeable, RevisionTrackable {
    var revision = 0
    func getNumberOfItems(in section: Int) -> Int { .zero }
    func onCellForItem(in section: Int, at index: Int) -> ViewModel? { nil }
    func onReuseIdentifierRequested(in section: Int, at index: Int) -> String { .empty }
    func onSizeForItem(in section: Int, at index: Int) -> Size { (.zero, .zero) }
}

/// `RevisionTrackable` in a window, where the update passes are UIKit's own (native observation on iOS 26 and later).
@MainActor
final class RevisionReloadHostedTests: XCTestCase {

    private final class SpyCollectionView: UICollectionView {
        private(set) var reloadCount = 0
        init() { super.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()) }
        required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }
        override func reloadData() {
            reloadCount += 1
            super.reloadData()
        }
    }

    private final class ListController: BaseCollectionViewableViewController<ItemsViewModel> {
        private(set) lazy var list = SpyCollectionView()

        @UIViewBuilder override var mainView: UIView {
            list.setConstraints { $0.snap(to: $1) }
        }

        override func setupView() {
            super.setupView()
            list.dataSource = self
            list.delegate = self
        }
    }

    private var window: UIWindow?

    override func tearDown() {
        window?.isHidden = true
        window = nil
        super.tearDown()
    }

    func test_revisionBumped_reloadsTheListInTheNextUpdatePass() async throws {
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        let viewModel = ItemsViewModel()
        let controller = ListController(viewModel: viewModel)
        let window = UIWindow(windowScene: scene)
        window.rootViewController = controller
        window.isHidden = false
        window.layoutIfNeeded()
        self.window = window
        let list = controller.list
        // UIKit reloads a list itself when its data source is set, so count from here.
        let baseline = list.reloadCount

        viewModel.revision += 1

        let reloaded = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in list.reloadCount == baseline + 1 }, object: nil)
        await fulfillment(of: [reloaded], timeout: transitionTimeout)
    }
}
