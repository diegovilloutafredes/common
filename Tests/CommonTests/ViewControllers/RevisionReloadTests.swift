//
//  RevisionReloadTests.swift
//

import Observation
import UIKit
import XCTest
@testable import Common

@available(iOS 17.0, *)
@Observable
private final class RevisionViewModel: CollectionViewDataSourceable, CollectionViewDelegateable, CollectionViewSizeable, RevisionTrackable {
    var revision = 0
    func getNumberOfItems(in section: Int) -> Int { .zero }
    func onCellForItem(in section: Int, at index: Int) -> ViewModel? { nil }
    func onReuseIdentifierRequested(in section: Int, at index: Int) -> String { .empty }
    func onSizeForItem(in section: Int, at index: Int) -> Size { (.zero, .zero) }
}

/// Has a tracked `revision` but doesn't adopt `RevisionTrackable`.
@available(iOS 17.0, *)
@Observable
private final class PlainViewModel: CollectionViewDataSourceable, CollectionViewDelegateable, CollectionViewSizeable {
    var revision = 0
    func getNumberOfItems(in section: Int) -> Int { .zero }
    func onCellForItem(in section: Int, at index: Int) -> ViewModel? { nil }
    func onReuseIdentifierRequested(in section: Int, at index: Int) -> String { .empty }
    func onSizeForItem(in section: Int, at index: Int) -> Size { (.zero, .zero) }
}

/// A `RevisionTrackable` view model makes the controller reload its lists. Manual mode on a detached view, which lays
/// out only when asked.
@available(iOS 17.0, *)
@MainActor
final class RevisionReloadTests: XCTestCase {

    private final class SpyCollectionView: UICollectionView {
        private(set) var reloadCount = 0
        init() { super.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()) }
        required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }
        override func reloadData() {
            reloadCount += 1
            super.reloadData()
        }
    }

    override func tearDown() {
        ObservationMode.override = nil
        super.tearDown()
    }

    /// Loads a controller serving `lists`, which ask it for data as UIKit's lists do, and runs its first pass.
    private func makeLoaded<ViewModelType>(_ viewModel: ViewModelType, serving lists: [SpyCollectionView]) -> BaseCollectionViewableViewController<ViewModelType> {
        ObservationMode.override = .manual
        let vc = BaseCollectionViewableViewController(viewModel: viewModel)
        vc.loadViewIfNeeded()
        vc.view.frame = .init(x: .zero, y: .zero, width: 320, height: 480)
        lists.forEach { _ = vc.numberOfSections(in: $0) }
        vc.view.layoutIfNeeded()
        return vc
    }

    /// Runs the pass a tracked change schedules.
    private func runScheduledPass(_ vc: UIViewController) async {
        let scheduled = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in vc.view.layer.needsLayout() }, object: nil)
        await fulfillment(of: [scheduled], timeout: callbackDeliveryTimeout)
        vc.view.layoutIfNeeded()
    }

    func test_firstPass_reloadsNothing() {
        let list = SpyCollectionView()

        _ = makeLoaded(RevisionViewModel(), serving: [list])

        XCTAssertEqual(list.reloadCount, .zero, "the list loads its data on its own the first time")
    }

    func test_revisionBumpedAfterTheFirstPass_reloadsOnTheNextPass() async {
        let viewModel = RevisionViewModel()
        let list = SpyCollectionView()
        let vc = makeLoaded(viewModel, serving: [list])

        viewModel.revision += 1
        await runScheduledPass(vc)

        XCTAssertEqual(list.reloadCount, 1)
    }

    func test_revisionBumped_reloadsEveryListTheControllerServes() async {
        let viewModel = RevisionViewModel()
        let lists = [SpyCollectionView(), SpyCollectionView()]
        let vc = makeLoaded(viewModel, serving: lists)

        viewModel.revision += 1
        await runScheduledPass(vc)

        XCTAssertEqual(lists.map(\.reloadCount), [1, 1])
    }

    func test_nonConformingViewModel_neverReloads() {
        let viewModel = PlainViewModel()
        let list = SpyCollectionView()
        let vc = makeLoaded(viewModel, serving: [list])

        viewModel.revision += 1
        vc.setNeedsContentUpdate()
        vc.view.layoutIfNeeded()

        XCTAssertEqual(list.reloadCount, .zero)
    }

    // MARK: - Each list against the revision it loaded at

    /// The defect: the first pass only recorded the revision, so a list that loaded earlier, at an older revision,
    /// kept its old rows. That happens when a list loads in `setupView()` and the view model loads its items in
    /// `onViewDidLoad()`, which runs after it.
    func test_listLoadedBeforeTheFirstPassAtAnOlderRevision_reloadsInThatPass() {
        ObservationMode.override = .manual
        let viewModel = RevisionViewModel()
        let list = SpyCollectionView()
        let vc = BaseCollectionViewableViewController(viewModel: viewModel)
        vc.loadViewIfNeeded()
        vc.view.frame = .init(x: .zero, y: .zero, width: 320, height: 480)
        _ = vc.numberOfSections(in: list)
        viewModel.revision = 1

        vc.view.layoutIfNeeded()

        XCTAssertEqual(list.reloadCount, 1)
    }

    /// Asks for its counts the way UIKit does, but counts its sections itself, without `super`.
    private final class OwnSectionCountViewController: BaseCollectionViewableViewController<RevisionViewModel> {
        override func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }
    }

    /// The defect: only `numberOfSections(in:)` registered a list, so a subclass that overrides it without `super`
    /// never had its list reloaded.
    func test_subclassCountingSectionsWithoutSuper_stillReloadsOnARevisionChange() async {
        ObservationMode.override = .manual
        let viewModel = RevisionViewModel()
        let list = SpyCollectionView()
        let vc = OwnSectionCountViewController(viewModel: viewModel)
        vc.loadViewIfNeeded()
        vc.view.frame = .init(x: .zero, y: .zero, width: 320, height: 480)
        _ = vc.numberOfSections(in: list)
        _ = vc.collectionView(list, numberOfItemsInSection: .zero)
        vc.view.layoutIfNeeded()

        viewModel.revision += 1
        await runScheduledPass(vc)

        XCTAssertEqual(list.reloadCount, 1)
    }

    // MARK: - Replacing the view model

    /// The defect: replacing the view model only re-cached it, and the revision the controller remembered carried
    /// over, so a new model at the same revision never reloaded the lists.
    func test_replacingTheViewModel_reloadsEveryServedListOnce_evenAtAnEqualRevision() {
        let lists = [SpyCollectionView(), SpyCollectionView()]
        let vc = makeLoaded(RevisionViewModel(), serving: lists)

        vc.viewModel = RevisionViewModel()
        vc.view.layoutIfNeeded()

        XCTAssertEqual(lists.map(\.reloadCount), [1, 1], "the pass the assignment schedules doesn't reload them again")
    }

    func test_replacingTheViewModel_withoutRevisionTracking_stillReloads() {
        let list = SpyCollectionView()
        let vc = makeLoaded(PlainViewModel(), serving: [list])

        vc.viewModel = PlainViewModel()

        XCTAssertEqual(list.reloadCount, 1)
    }
}
