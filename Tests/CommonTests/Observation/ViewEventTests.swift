//
//  ViewEventTests.swift
//

import Observation
import UIKit
import XCTest
@testable import Common

final class ViewEventTests: XCTestCase {

    private enum Event: Equatable { case saved, failed(String) }

    func test_twoEventsWithEqualPayloads_haveDistinctIdentities() {
        let first = ViewEvent(Event.saved)
        let second = ViewEvent(Event.saved)
        XCTAssertNotEqual(first.id, second.id)
        XCTAssertEqual(first.payload, second.payload)
    }

    func test_cursor_consumesAnEventOnceAcrossRepeatedPasses() {
        var cursor = ViewEventCursor()
        let event = ViewEvent(Event.saved)
        var handled: [Event] = []

        (1...3).forEach { _ in cursor.consume(event) { handled.append($0) } }

        XCTAssertEqual(handled, [.saved])
    }

    func test_cursor_ignoresNil() {
        var cursor = ViewEventCursor()
        var handledCount: Int = .zero

        cursor.consume(ViewEvent<Event>?.none) { _ in handledCount += 1 }

        XCTAssertEqual(handledCount, .zero)
    }

    func test_cursor_nilDoesNotForgetTheConsumedEvent() {
        var cursor = ViewEventCursor()
        let event = ViewEvent(Event.saved)
        var handledCount: Int = .zero

        cursor.consume(event) { _ in handledCount += 1 }
        cursor.consume(ViewEvent<Event>?.none) { _ in handledCount += 1 }
        cursor.consume(event) { _ in handledCount += 1 }

        XCTAssertEqual(handledCount, 1)
    }

    func test_cursor_consumesASecondEventOnce() {
        var cursor = ViewEventCursor()
        var handled: [Event] = []

        cursor.consume(ViewEvent(Event.saved)) { handled.append($0) }
        let second = ViewEvent(Event.failed("offline"))
        cursor.consume(second) { handled.append($0) }
        cursor.consume(second) { handled.append($0) }

        XCTAssertEqual(handled, [.saved, .failed("offline")])
    }

    // MARK: - consume(_:ifAble:_:)

    func test_cursor_unable_leavesTheEventPending() {
        var cursor = ViewEventCursor()
        let event = ViewEvent(Event.saved)
        var handled: [Event] = []

        cursor.consume(event, ifAble: false) { handled.append($0) }
        XCTAssertEqual(handled, [])

        cursor.consume(event, ifAble: true) { handled.append($0) }
        cursor.consume(event, ifAble: true) { handled.append($0) }
        XCTAssertEqual(handled, [.saved], "handled once when able, never again")
    }

    func test_cursor_replacedWhilePending_handlesOnlyTheSecond() {
        var cursor = ViewEventCursor()
        var handled: [Event] = []

        cursor.consume(ViewEvent(Event.saved), ifAble: false) { handled.append($0) }
        let second = ViewEvent(Event.failed("offline"))
        cursor.consume(second, ifAble: false) { handled.append($0) }
        cursor.consume(second, ifAble: true) { handled.append($0) }

        XCTAssertEqual(handled, [.failed("offline")])
    }

    func test_cursor_ifAble_ignoresNilAndConsumedEventsLikeConsume() {
        var cursor = ViewEventCursor()
        let event = ViewEvent(Event.saved)
        var handledCount: Int = .zero

        cursor.consume(ViewEvent<Event>?.none, ifAble: true) { _ in handledCount += 1 }
        cursor.consume(event) { _ in handledCount += 1 }
        cursor.consume(event, ifAble: true) { _ in handledCount += 1 }

        XCTAssertEqual(handledCount, 1)
    }

    // MARK: - One cursor, several slots

    /// The defect: the cursor kept only the last id it consumed, so two slots read through one cursor overwrote each
    /// other's id and both handlers ran again on every pass.
    func test_cursor_sharedByTwoSlots_handlesEachFiringOnce() {
        var cursor = ViewEventCursor()
        let alert = ViewEvent(Event.saved)
        let snackbar = ViewEvent(Event.failed("offline"))
        var handled: [Event] = []

        (1...4).forEach { _ in
            cursor.consume(alert) { handled.append($0) }
            cursor.consume(snackbar) { handled.append($0) }
        }

        XCTAssertEqual(handled, [.saved, .failed("offline")])
    }

    /// A slot that keeps a handled event beside a slot that fires more often than the cursor remembers: the quiet
    /// slot's id is seen again on every pass, so it is never the one the cursor forgets.
    func test_cursor_sharedSlots_aBusySlotDoesNotEvictTheQuietOne() {
        var cursor = ViewEventCursor()
        let quiet = ViewEvent(Event.saved)
        var handled: [Event] = []

        cursor.consume(quiet) { handled.append($0) }
        for firing in 1...9 {
            cursor.consume(ViewEvent(Event.failed("\(firing)"))) { handled.append($0) }
            cursor.consume(quiet) { handled.append($0) }
        }

        XCTAssertEqual(handled.filter { $0 == .saved }.count, 1, "the quiet slot's event is handled once")
        XCTAssertEqual(handled.count, 10, "each busy firing is handled once")
    }

    /// The same while the quiet slot is read with `ifAble: false`, as under a sheet: an id the cursor already handled
    /// still counts as seen, so the event isn't handled again once the controller can act.
    func test_cursor_handledEventReadWhileUnable_staysRemembered() {
        var cursor = ViewEventCursor()
        let quiet = ViewEvent(Event.saved)
        var handled: [Event] = []

        cursor.consume(quiet) { handled.append($0) }
        for firing in 1...9 {
            cursor.consume(ViewEvent(Event.failed("\(firing)"))) { handled.append($0) }
            cursor.consume(quiet, ifAble: false) { handled.append($0) }
        }
        cursor.consume(quiet, ifAble: true) { handled.append($0) }

        XCTAssertEqual(handled.filter { $0 == .saved }.count, 1)
    }

    // MARK: - take(_:ifAble:)

    func test_take_returnsThePayloadOnce() {
        var cursor = ViewEventCursor()
        let event = ViewEvent(Event.saved)

        XCTAssertEqual(cursor.take(event), .saved)
        XCTAssertNil(cursor.take(event))
        XCTAssertNil(cursor.take(event))
    }

    func test_take_returnsNilForNil() {
        var cursor = ViewEventCursor()

        XCTAssertNil(cursor.take(ViewEvent<Event>?.none))
    }

    func test_take_whileUnable_leavesTheEventPending() {
        var cursor = ViewEventCursor()
        let event = ViewEvent(Event.saved)

        XCTAssertNil(cursor.take(event, ifAble: false))
        XCTAssertEqual(cursor.take(event), .saved)
        XCTAssertNil(cursor.take(event))
    }

    func test_takeAndConsume_shareTheirBookkeeping() {
        var cursor = ViewEventCursor()
        let event = ViewEvent(Event.saved)
        var handledCount: Int = .zero

        XCTAssertEqual(cursor.take(event), .saved)
        cursor.consume(event) { _ in handledCount += 1 }

        XCTAssertEqual(handledCount, .zero)
    }
}

// MARK: - Update passes

@available(iOS 17.0, *)
@Observable
private final class EventSource {
    var event: ViewEvent<String>?
}

/// Drives `consume(_:ifAble:_:)` through a controller's update passes, in manual mode on a detached view, which lays
/// out only when asked.
@available(iOS 17.0, *)
@MainActor
final class ViewEventCursorUpdatePassTests: XCTestCase {

    private final class EventViewController: BaseViewController {
        var source: EventSource?
        /// Not observed, like `presentedViewController`: changing it schedules no pass.
        var canAct = false
        private(set) var handled: [String] = []
        /// Counts the hook's runs, so "nothing was handled" can't pass just because no pass ran.
        private(set) var passes: Int = .zero
        private var cursor = ViewEventCursor()

        override func updateContent() {
            super.updateContent()
            passes += 1
            cursor.consume(source?.event, ifAble: canAct) { handled.append($0) }
        }
    }

    /// Acts on a taken payload by rendering itself again, right away, the way a handler that lays out the window can.
    /// `take` has returned by then, so the nested pass takes from the same cursor. Written with `consume`, the nested
    /// pass would reach the cursor while the outer `consume` still holds it, and the process would trap on exclusive
    /// access, so that shape isn't run here.
    private final class ReentrantViewController: BaseViewController {
        var source: EventSource?
        private(set) var handled: [String] = []
        private(set) var deepestPass: Int = .zero
        private var depth: Int = .zero
        private var cursor = ViewEventCursor()

        override func updateContent() {
            super.updateContent()
            depth += 1
            defer { depth -= 1 }
            deepestPass = max(deepestPass, depth)
            if let payload = cursor.take(source?.event) {
                handled.append(payload)
                if payload == "first" {
                    source?.event = .init("second")
                    renderNow()
                }
            }
        }

        /// Runs this controller's pass from inside the current one.
        private func renderNow() {
            setNeedsContentUpdate()
            if #available(iOS 26.0, *), ObservationMode.current == .native {
                updateProperties()
            } else {
                viewWillLayoutSubviews()
            }
        }
    }

    private var window: UIWindow?

    override func tearDown() {
        ObservationMode.override = nil
        window?.isHidden = true
        window = nil
        super.tearDown()
    }

    private func makeLoaded(_ source: EventSource) -> EventViewController {
        ObservationMode.override = .manual
        let vc = EventViewController()
        vc.source = source
        vc.loadViewIfNeeded()
        vc.view.frame = .init(x: .zero, y: .zero, width: 320, height: 480)
        vc.view.layoutIfNeeded()
        return vc
    }

    /// Assigns the event and runs the pass its invalidation schedules.
    private func fire(_ payload: String, on source: EventSource, rendering vc: EventViewController) async {
        source.event = .init(payload)
        let scheduled = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in vc.view.layer.needsLayout() }, object: nil)
        await fulfillment(of: [scheduled], timeout: callbackDeliveryTimeout)
        vc.view.layoutIfNeeded()
    }

    func test_eventIsHeldWhileUnableAndHandledOnceWhenAble() async {
        let source = EventSource()
        let vc = makeLoaded(source)
        let passesBefore = vc.passes

        await fire("saved", on: source, rendering: vc)
        XCTAssertEqual(vc.passes, passesBefore + 1, "the firing ran one pass")
        XCTAssertEqual(vc.handled, [], "the pass ran while the controller couldn't act")

        vc.canAct = true
        vc.setNeedsContentUpdate()
        vc.view.layoutIfNeeded()
        XCTAssertEqual(vc.handled, ["saved"])

        vc.setNeedsContentUpdate()
        vc.view.layoutIfNeeded()
        XCTAssertEqual(vc.handled, ["saved"], "a later pass doesn't handle it again")
    }

    func test_pendingEventIsHandledInThePassSetNeedsContentUpdateTriggers() async {
        let source = EventSource()
        let vc = makeLoaded(source)
        await fire("saved", on: source, rendering: vc)
        let passesBefore = vc.passes

        vc.canAct = true
        vc.view.setNeedsLayout()
        vc.view.layoutIfNeeded()
        XCTAssertEqual(vc.passes, passesBefore, "an unrelated layout pass skips the hook")
        XCTAssertEqual(vc.handled, [], "the cursor schedules no pass")

        vc.setNeedsContentUpdate()
        vc.view.layoutIfNeeded()
        XCTAssertEqual(vc.passes, passesBefore + 1)
        XCTAssertEqual(vc.handled, ["saved"])
    }

    // MARK: - Acting on a taken event

    func test_manualMode_actingOnATakenEventCanRenderTheSameControllerAgain() {
        ObservationMode.override = .manual
        let source = EventSource()
        source.event = .init("first")
        let vc = ReentrantViewController()
        vc.source = source
        vc.loadViewIfNeeded()
        vc.view.frame = .init(x: .zero, y: .zero, width: 320, height: 480)

        vc.view.layoutIfNeeded()

        XCTAssertEqual(vc.handled, ["first", "second"])
        XCTAssertEqual(vc.deepestPass, 2, "the second event was handled by a pass nested in the first")
    }

    func test_nativeMode_actingOnATakenEventCanRenderTheSameControllerAgain() throws {
        guard #available(iOS 26.0, *) else { throw XCTSkip("native path needs iOS 26") }
        ObservationMode.override = .native
        let source = EventSource()
        source.event = .init("first")
        let vc = ReentrantViewController()
        vc.source = source
        let window = UIWindow(frame: .init(x: .zero, y: .zero, width: 320, height: 480))
        window.rootViewController = vc
        window.isHidden = false
        self.window = window

        vc.updatePropertiesIfNeeded()

        XCTAssertEqual(vc.handled, ["first", "second"])
        XCTAssertEqual(vc.deepestPass, 2, "the second event was handled by a pass nested in the first")
    }
}
