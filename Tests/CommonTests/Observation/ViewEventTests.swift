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
        private var cursor = ViewEventCursor()

        override func updateContent() {
            super.updateContent()
            cursor.consume(source?.event, ifAble: canAct) { handled.append($0) }
        }
    }

    override func tearDown() {
        ObservationMode.override = nil
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

        await fire("saved", on: source, rendering: vc)
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

        vc.canAct = true
        vc.view.setNeedsLayout()
        vc.view.layoutIfNeeded()
        XCTAssertEqual(vc.handled, [], "the cursor schedules no pass, and an unrelated layout pass skips the hook")

        vc.setNeedsContentUpdate()
        vc.view.layoutIfNeeded()
        XCTAssertEqual(vc.handled, ["saved"])
    }
}
