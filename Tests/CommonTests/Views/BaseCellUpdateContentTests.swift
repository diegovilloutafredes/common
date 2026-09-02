//
//  BaseCellUpdateContentTests.swift
//

import UIKit
import XCTest
@testable import Common

@available(iOS 17.0, *)
@MainActor
final class BaseCellUpdateContentTests: XCTestCase {

    private final class CounterCell: BaseViewModelableCell<ObservedCounter> {
        private(set) var updates: Int = .zero
        private(set) var rendered: Int = -1
        override func updateContent() {
            updates += 1
            rendered = viewModel?.value ?? -1
        }
    }

    private final class CounterHeader: BaseViewModelableReusableView<ObservedCounter> {
        private(set) var updates: Int = .zero
        override func updateContent() { updates += 1 }
    }

    private final class CounterView: BaseViewModelableView<ObservedCounter> {
        private(set) var updates: Int = .zero
        override func updateContent() { updates += 1 }
    }

    private var window: UIWindow!

    override func setUp() {
        super.setUp()
        window = UIWindow(frame: .init(x: .zero, y: .zero, width: 200, height: 200))
        window.isHidden = false
    }

    override func tearDown() {
        ObservationMode.override = nil
        window.isHidden = true
        window = nil
        super.tearDown()
    }

    /// Manual-mode tests keep the view detached (a visible window lays out on its own
    /// and blurs scheduling assertions); the native test hosts it for a real update pass.
    private func size(_ view: UIView) { view.frame = window.bounds }
    private func host(_ view: UIView) { size(view); window.addSubview(view) }

    func test_cell_assigningViewModel_manualMode_schedulesLayoutAndHookReadsNewModel() {
        ObservationMode.override = .manual
        let cell = CounterCell(frame: .zero)
        size(cell)
        cell.layoutIfNeeded()
        XCTAssertEqual(cell.rendered, -1)

        let model = ObservedCounter()
        model.value = 4
        cell.viewModel = model
        XCTAssertTrue(cell.layer.needsLayout(), "viewModel assignment must invalidate content")

        cell.layoutIfNeeded()
        XCTAssertEqual(cell.rendered, 4)
    }

    func test_cell_manualMode_observedChangeOnCurrentModelSchedulesLayout() async {
        ObservationMode.override = .manual
        let model = ObservedCounter()
        let cell = CounterCell(frame: .zero)
        size(cell)
        cell.viewModel = model
        cell.layoutIfNeeded()
        XCTAssertFalse(cell.layer.needsLayout())

        model.value = 9
        let scheduled = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in cell.layer.needsLayout() }, object: nil)
        await fulfillment(of: [scheduled], timeout: callbackDeliveryTimeout)
        cell.layoutIfNeeded()
        XCTAssertEqual(cell.rendered, 9)
    }

    /// Reuse: a stale onChange from the previous model may fire once more; it only
    /// schedules layout, and the next pass reads the *current* model.
    func test_cell_manualMode_swappedModelIsReadAfterStaleInvalidation() async {
        ObservationMode.override = .manual
        let first = ObservedCounter()
        let second = ObservedCounter()
        second.value = 2
        let cell = CounterCell(frame: .zero)
        size(cell)
        cell.viewModel = first
        cell.layoutIfNeeded()

        cell.viewModel = second
        cell.layoutIfNeeded()
        XCTAssertEqual(cell.rendered, 2)

        first.value = 100   // stale tracking from the first pass
        try? await Task.sleep(nanoseconds: 100_000_000)
        cell.layoutIfNeeded()
        XCTAssertEqual(cell.rendered, 2, "a stale invalidation must never render the old model")
    }

    /// Improvement 2: cell scroll/resize layouts must not re-run the hook without an invalidation.
    func test_cell_manualMode_unrelatedLayoutPassDoesNotRerunHook() {
        ObservationMode.override = .manual
        let cell = CounterCell(frame: .zero)
        size(cell)
        cell.viewModel = ObservedCounter()
        cell.layoutIfNeeded()
        let after = cell.updates

        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        XCTAssertEqual(cell.updates, after, "no invalidation, no re-run")
    }

    func test_cell_nativeMode_assigningViewModelRerunsHookOnNextPropertiesPass() throws {
        guard #available(iOS 26.0, *) else { throw XCTSkip("native path needs iOS 26") }
        ObservationMode.override = .native
        let cell = CounterCell(frame: .zero)
        host(cell)
        cell.updatePropertiesIfNeeded()
        let before = cell.updates

        let model = ObservedCounter()
        model.value = 6
        cell.viewModel = model
        cell.updatePropertiesIfNeeded()
        XCTAssertEqual(cell.updates, before + 1)
        XCTAssertEqual(cell.rendered, 6)
    }

    func test_reusableView_assigningViewModel_manualMode_schedulesLayout() {
        ObservationMode.override = .manual
        let header = CounterHeader(frame: .zero)
        size(header)
        header.layoutIfNeeded()
        header.viewModel = ObservedCounter()
        XCTAssertTrue(header.layer.needsLayout())
    }

    func test_viewModelableView_assigningViewModel_manualMode_schedulesLayout() {
        ObservationMode.override = .manual
        let view = CounterView(viewModel: ObservedCounter())
        size(view)
        view.layoutIfNeeded()
        view.viewModel = ObservedCounter()
        XCTAssertTrue(view.layer.needsLayout())
    }
}
