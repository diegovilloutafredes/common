//
//  BaseViewControllerUpdateContentTests.swift
//

import UIKit
import XCTest
@testable import Common

@available(iOS 17.0, *)
@MainActor
final class BaseViewControllerUpdateContentTests: XCTestCase {

    private final class CounterViewModel: ViewLifecycleable {
        let model: ObservedCounter
        private(set) var updates: Int = .zero
        private(set) var rendered: Int = -1
        init(model: ObservedCounter) { self.model = model }
        func onUpdateProperties() {
            updates += 1
            rendered = model.value
        }
    }

    private var window: UIWindow?

    override func tearDown() {
        ObservationMode.override = nil
        window?.isHidden = true
        window = nil
        super.tearDown()
    }

    /// Native tests need a real update pass, so the controller is hosted in a window.
    private func makeHosted(_ viewModel: CounterViewModel) -> BaseViewModelableViewController<CounterViewModel> {
        let vc = BaseViewModelableViewController<CounterViewModel>(viewModel: viewModel)
        let window = UIWindow(frame: .init(x: .zero, y: .zero, width: 320, height: 480))
        window.rootViewController = vc
        window.isHidden = false
        self.window = window
        return vc
    }

    /// Manual / unavailable tests stay off-window: a visible window lays out on its own
    /// run-loop turns, which would blur "did the change schedule a pass?" assertions.
    /// A detached view lays out only when asked, so `layer.needsLayout()` is stable.
    private func makeLoaded(_ viewModel: CounterViewModel) -> BaseViewModelableViewController<CounterViewModel> {
        let vc = BaseViewModelableViewController<CounterViewModel>(viewModel: viewModel)
        vc.loadViewIfNeeded()
        vc.view.frame = .init(x: .zero, y: .zero, width: 320, height: 480)
        return vc
    }

    private func layoutScheduled(_ vc: UIViewController) -> XCTNSPredicateExpectation {
        XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in vc.view.layer.needsLayout() }, object: nil)
    }

    func test_nativeMode_updatePropertiesForwardsToViewModelAndRerunsOnChange() throws {
        guard #available(iOS 26.0, *) else { throw XCTSkip("native path needs iOS 26") }
        ObservationMode.override = .native
        let model = ObservedCounter()
        let viewModel = CounterViewModel(model: model)
        let vc = makeHosted(viewModel)

        vc.updatePropertiesIfNeeded()
        XCTAssertEqual(viewModel.updates, 1)
        XCTAssertEqual(viewModel.rendered, .zero)

        model.value = 5
        vc.updatePropertiesIfNeeded()
        XCTAssertEqual(viewModel.updates, 2, "UIKit must re-run updateProperties after a tracked read changed")
        XCTAssertEqual(viewModel.rendered, 5)
    }

    func test_manualMode_viewWillLayoutSubviewsRunsHookAndChangeSchedulesLayout() async {
        ObservationMode.override = .manual
        let model = ObservedCounter()
        let viewModel = CounterViewModel(model: model)
        let vc = makeLoaded(viewModel)

        vc.view.layoutIfNeeded()
        XCTAssertEqual(viewModel.updates, 1)
        XCTAssertFalse(vc.view.layer.needsLayout())

        model.value = 3
        await fulfillment(of: [layoutScheduled(vc)], timeout: callbackDeliveryTimeout)
        XCTAssertEqual(viewModel.updates, 1, "invalidation only schedules; nothing is read until the next pass")

        vc.view.layoutIfNeeded()
        XCTAssertEqual(viewModel.updates, 2)
        XCTAssertEqual(viewModel.rendered, 3)
    }

    func test_unavailableMode_changeDoesNotScheduleLayout() async throws {
        ObservationMode.override = .unavailable
        let model = ObservedCounter()
        let viewModel = CounterViewModel(model: model)
        let vc = makeLoaded(viewModel)

        vc.view.layoutIfNeeded()
        XCTAssertEqual(viewModel.updates, 1)

        model.value = 3
        try await Task.sleep(nanoseconds: 300_000_000)
        XCTAssertEqual(viewModel.updates, 1, "untracked mode must not re-run the hook on its own")

        vc.view.setNeedsLayout()
        vc.view.layoutIfNeeded()
        XCTAssertEqual(viewModel.updates, 2, "the hook still runs on every explicit layout pass")
        XCTAssertEqual(viewModel.rendered, 3)
    }

    func test_setNeedsContentUpdate_manualMode_schedulesLayout() {
        ObservationMode.override = .manual
        let vc = makeLoaded(CounterViewModel(model: ObservedCounter()))
        vc.view.layoutIfNeeded()
        XCTAssertFalse(vc.view.layer.needsLayout())

        vc.setNeedsContentUpdate()
        XCTAssertTrue(vc.view.layer.needsLayout())
    }

    func test_setNeedsContentUpdate_nativeMode_rerunsHookOnNextPropertiesPass() throws {
        guard #available(iOS 26.0, *) else { throw XCTSkip("native path needs iOS 26") }
        ObservationMode.override = .native
        let viewModel = CounterViewModel(model: ObservedCounter())
        let vc = makeHosted(viewModel)
        vc.updatePropertiesIfNeeded()
        XCTAssertEqual(viewModel.updates, 1)

        vc.setNeedsContentUpdate()
        vc.updatePropertiesIfNeeded()
        XCTAssertEqual(viewModel.updates, 2)
    }

    func test_setNeedsContentUpdate_beforeViewLoads_doesNotLoadTheView() {
        ObservationMode.override = .manual
        let vc = BaseViewModelableViewController<CounterViewModel>(viewModel: .init(model: ObservedCounter()))
        vc.setNeedsContentUpdate()
        XCTAssertFalse(vc.isViewLoaded)
    }

    func test_reassigningViewModel_manualMode_schedulesLayoutAndHookReadsNewViewModel() {
        ObservationMode.override = .manual
        let first = CounterViewModel(model: ObservedCounter())
        let vc = makeLoaded(first)
        vc.view.layoutIfNeeded()
        XCTAssertEqual(first.updates, 1)

        let secondModel = ObservedCounter()
        secondModel.value = 8
        let second = CounterViewModel(model: secondModel)
        vc.viewModel = second
        XCTAssertTrue(vc.view.layer.needsLayout(), "swapping the view model must invalidate content")

        vc.view.layoutIfNeeded()
        XCTAssertEqual(second.updates, 1)
        XCTAssertEqual(second.rendered, 8)
        XCTAssertEqual(first.updates, 1, "the old view model is no longer driven")
    }
}
