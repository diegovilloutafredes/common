//
//  BaseViewUpdateContentTests.swift
//

import UIKit
import XCTest
@testable import Common

@available(iOS 17.0, *)
@MainActor
final class BaseViewUpdateContentTests: XCTestCase {

    private final class CounterView: BaseView {
        let model: ObservedCounter
        private(set) var updates: Int = .zero
        private(set) var rendered: Int = -1
        private lazy var label = UILabel()

        init(model: ObservedCounter) {
            self.model = model
            super.init()
        }

        @UIViewBuilder override var mainView: UIView {
            VStack { label }
        }

        // Side-effect free on purpose: a label text change would itself call
        // setNeedsLayout and blur the "did observation schedule layout?" assertions.
        override func updateContent() {
            updates += 1
            rendered = model.value
        }
    }

    /// Writes model state into a label so a change affects intrinsic size; counts the
    /// view's own layout passes.
    private final class TextView: BaseView {
        let model: ObservedCounter
        private(set) var layoutPasses: Int = .zero
        let label = UILabel()

        init(model: ObservedCounter) {
            self.model = model
            super.init()
        }

        @UIViewBuilder override var mainView: UIView {
            VStack(alignment: .leading) { label }
        }

        override func updateContent() { label.text = "\(model.value)" }

        override func layoutSubviews() {
            layoutPasses += 1
            super.layoutSubviews()
        }
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

    /// Native tests are hosted in the window (real update pass). Manual / unavailable
    /// tests use `makeDetached`: a visible window lays out on its own run-loop turns,
    /// which would blur "did the change schedule a pass?" assertions; a detached view
    /// lays out only when asked, so `layer.needsLayout()` is stable.
    private func makeHosted(_ model: ObservedCounter) -> CounterView {
        let view = makeDetached(model)
        window.addSubview(view)
        return view
    }

    private func makeDetached(_ model: ObservedCounter) -> CounterView {
        let view = CounterView(model: model)
        view.frame = window.bounds
        // Install Common's layoutSubviews swizzle on this view so the test proves
        // it coexists with UIKit's tracking wrapper (spec §7.4 gate 1).
        view.onLayoutSubviews { _ in }
        return view
    }

    private func layoutScheduled(_ view: UIView) -> XCTNSPredicateExpectation {
        XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in view.layer.needsLayout() }, object: nil)
    }

    func test_nativeMode_updatePropertiesRunsHookAndRerunsOnChange_withSwizzleInstalled() throws {
        guard #available(iOS 26.0, *) else { throw XCTSkip("native path needs iOS 26") }
        ObservationMode.override = .native
        let model = ObservedCounter()
        let view = makeHosted(model)

        view.updatePropertiesIfNeeded()
        XCTAssertEqual(view.updates, 1)

        model.value = 7
        view.updatePropertiesIfNeeded()
        XCTAssertEqual(view.updates, 2)
        XCTAssertEqual(view.rendered, 7)
    }

    func test_nativeMode_layoutSubviewsDoesNotRunHook() throws {
        guard #available(iOS 26.0, *) else { throw XCTSkip("native path needs iOS 26") }
        ObservationMode.override = .native
        let view = makeHosted(ObservedCounter())
        view.updatePropertiesIfNeeded()
        let after = view.updates

        view.setNeedsLayout()
        view.layoutIfNeeded()
        XCTAssertEqual(view.updates, after, "in native mode only updateProperties drives the hook")
    }

    func test_manualMode_layoutSubviewsRunsHookAndChangeSchedulesLayout() async {
        ObservationMode.override = .manual
        let model = ObservedCounter()
        let view = makeDetached(model)

        view.layoutIfNeeded()
        XCTAssertEqual(view.updates, 1)
        XCTAssertFalse(view.layer.needsLayout())

        model.value = 3
        await fulfillment(of: [layoutScheduled(view)], timeout: callbackDeliveryTimeout)
        XCTAssertEqual(view.updates, 1, "invalidation only schedules; nothing is read until the next pass")

        view.layoutIfNeeded()
        XCTAssertEqual(view.updates, 2)
        XCTAssertEqual(view.rendered, 3)
    }

    func test_unavailableMode_hookRunsEachLayoutButChangeDoesNotScheduleLayout() async throws {
        ObservationMode.override = .unavailable
        let model = ObservedCounter()
        let view = makeDetached(model)

        view.layoutIfNeeded()
        XCTAssertEqual(view.updates, 1)

        model.value = 3
        try await Task.sleep(nanoseconds: 300_000_000)
        XCTAssertEqual(view.updates, 1, "untracked mode must not re-run the hook on its own")

        view.setNeedsLayout()
        view.layoutIfNeeded()
        XCTAssertEqual(view.updates, 2, "the hook still runs on every explicit layout pass")
        XCTAssertEqual(view.rendered, 3)
    }

    /// Improvement 2: in manual mode the hook is invalidation-driven. A layout pass caused
    /// by something else (rotation, scrolling) must not re-run it.
    func test_manualMode_unrelatedLayoutPassDoesNotRerunHook() {
        ObservationMode.override = .manual
        let view = makeDetached(ObservedCounter())
        view.layoutIfNeeded()
        XCTAssertEqual(view.updates, 1)

        view.setNeedsLayout()
        view.layoutIfNeeded()
        XCTAssertEqual(view.updates, 1, "no invalidation, no re-run")

        view.setNeedsContentUpdate()
        view.layoutIfNeeded()
        XCTAssertEqual(view.updates, 2)
    }

    /// Improvement 1: the manual hook runs before the view's own layout, so a size-affecting
    /// change is resolved in the same pass — one `layoutIfNeeded()` leaves the label at its
    /// new width with nothing pending.
    func test_manualMode_contentChangeIsLaidOutInTheSamePass() {
        ObservationMode.override = .manual
        let model = ObservedCounter()
        let view = TextView(model: model)
        view.frame = window.bounds
        view.layoutIfNeeded()
        let narrow = view.label.frame.width
        XCTAssertGreaterThan(narrow, .zero)
        let passesBefore = view.layoutPasses

        model.value = 1_000_000
        XCTAssertTrue(view.layer.needsLayout(), "main-thread mutation invalidates synchronously")
        view.layoutIfNeeded()

        XCTAssertEqual(view.label.frame.width, view.label.intrinsicContentSize.width, accuracy: 0.5)
        XCTAssertGreaterThan(view.label.frame.width, narrow)
        XCTAssertFalse(view.layer.needsLayout(), "no second pass may be pending")
        XCTAssertEqual(view.layoutPasses, passesBefore + 1, "exactly one pass for one change")
    }

    func test_setNeedsContentUpdate_manualMode_schedulesLayout() {
        ObservationMode.override = .manual
        let view = makeDetached(ObservedCounter())
        view.layoutIfNeeded()
        XCTAssertFalse(view.layer.needsLayout())

        view.setNeedsContentUpdate()
        XCTAssertTrue(view.layer.needsLayout())
    }

    func test_setNeedsContentUpdate_nativeMode_rerunsHookOnNextPropertiesPass() throws {
        guard #available(iOS 26.0, *) else { throw XCTSkip("native path needs iOS 26") }
        ObservationMode.override = .native
        let view = makeHosted(ObservedCounter())
        view.updatePropertiesIfNeeded()
        XCTAssertEqual(view.updates, 1)

        view.setNeedsContentUpdate()
        view.updatePropertiesIfNeeded()
        XCTAssertEqual(view.updates, 2)
    }
}
