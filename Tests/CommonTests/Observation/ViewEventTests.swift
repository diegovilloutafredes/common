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

    // MARK: - Identity and equality

    /// A payload with no conformances: equality doesn't depend on the payload's.
    private struct Opaque {}

    func test_eventsWithEqualPayloads_compareUnequal() {
        let first = ViewEvent(Event.saved)
        let second = ViewEvent(Event.saved)

        XCTAssertNotEqual(first, second)
        XCTAssertNotEqual(first.id, second.id)
    }

    func test_aCopy_comparesEqual() {
        let event = ViewEvent(Opaque())
        let copy = event

        XCTAssertEqual(copy, event)
    }

    func test_identifiableID_isTheEventsID() {
        let event = ViewEvent(Opaque())

        XCTAssertEqual(identifier(of: event), event.id)
    }

    private func identifier<Item: Identifiable>(of item: Item) -> Item.ID { item.id }

    // MARK: - skip(_:)

    func test_skip_marksTheEventHandled() {
        var cursor = ViewEventCursor()
        let event = ViewEvent(Event.saved)
        var handledCount: Int = .zero

        cursor.skip(event)

        XCTAssertNil(cursor.take(event))
        cursor.consume(event) { _ in handledCount += 1 }
        XCTAssertEqual(handledCount, .zero)
    }

    func test_skip_handsALaterEventOverOnce() {
        var cursor = ViewEventCursor()
        cursor.skip(ViewEvent(Event.saved))
        let later = ViewEvent(Event.failed("offline"))

        XCTAssertEqual(cursor.take(later), .failed("offline"))
        XCTAssertNil(cursor.take(later))
    }

    func test_skipNil_changesNothing() {
        var cursor = ViewEventCursor()
        cursor.skip(ViewEvent<Event>?.none)
        let event = ViewEvent(Event.saved)

        XCTAssertEqual(cursor.take(event), .saved)
        XCTAssertNil(cursor.take(event))
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

// MARK: - Assigning a slot

/// An `@Observable` model doesn't notify when the assigned value equals the current one, and events are equal by id:
/// assigning a slot the event it already holds doesn't re-run the observing hook, while a new event with the same
/// payload does. Manual mode on a detached view, native mode in a window.
@available(iOS 17.0, *)
@MainActor
final class ViewEventSlotAssignmentTests: XCTestCase {

    private final class TakingViewController: BaseViewController {
        var source: EventSource?
        private(set) var handled: [String] = []
        private(set) var passes: Int = .zero
        private var cursor = ViewEventCursor()

        override func updateContent() {
            super.updateContent()
            passes += 1
            if let payload = cursor.take(source?.event) { handled.append(payload) }
        }
    }

    private var window: UIWindow?

    override func tearDown() {
        ObservationMode.override = nil
        window?.isHidden = true
        window = nil
        super.tearDown()
    }

    /// A controller whose first pass took `source`'s event, in the given mode.
    private func makeRendered(_ source: EventSource, mode: ObservationMode) -> TakingViewController {
        ObservationMode.override = mode
        let vc = TakingViewController()
        vc.source = source
        if mode == .native {
            let window = UIWindow(frame: .init(x: .zero, y: .zero, width: 320, height: 480))
            window.rootViewController = vc
            window.isHidden = false
            self.window = window
        } else {
            vc.loadViewIfNeeded()
            vc.view.frame = .init(x: .zero, y: .zero, width: 320, height: 480)
        }
        runPendingPass(vc)
        return vc
    }

    /// Runs the controller's pass if one is scheduled.
    private func runPendingPass(_ vc: UIViewController) {
        if #available(iOS 26.0, *), ObservationMode.current == .native {
            vc.updatePropertiesIfNeeded()
        } else {
            vc.view.layoutIfNeeded()
        }
    }

    private func assertReassigningTheHeldEventDoesNotRerunTheHook(mode: ObservationMode, file: StaticString = #filePath, line: UInt = #line) {
        let source = EventSource()
        source.event = .init("saved")
        let vc = makeRendered(source, mode: mode)
        XCTAssertEqual(vc.passes, 1, file: file, line: line)
        XCTAssertEqual(vc.handled, ["saved"], file: file, line: line)

        let held = source.event
        source.event = held
        runPendingPass(vc)

        XCTAssertEqual(vc.passes, 1, "assigning the held event doesn't notify", file: file, line: line)
        XCTAssertEqual(vc.handled, ["saved"], file: file, line: line)
    }

    private func assertANewEventWithTheSamePayloadIsTakenOnce(mode: ObservationMode, file: StaticString = #filePath, line: UInt = #line) {
        let source = EventSource()
        source.event = .init("saved")
        let vc = makeRendered(source, mode: mode)

        source.event = .init("saved")
        runPendingPass(vc)
        XCTAssertEqual(vc.passes, 2, "a new event notifies, whatever its payload", file: file, line: line)
        XCTAssertEqual(vc.handled, ["saved", "saved"], file: file, line: line)

        vc.setNeedsContentUpdate()
        runPendingPass(vc)
        XCTAssertEqual(vc.passes, 3, file: file, line: line)
        XCTAssertEqual(vc.handled, ["saved", "saved"], "the cursor hands it over once", file: file, line: line)
    }

    func test_manualMode_reassigningTheHeldEvent_doesNotRerunTheHook() {
        assertReassigningTheHeldEventDoesNotRerunTheHook(mode: .manual)
    }

    func test_nativeMode_reassigningTheHeldEvent_doesNotRerunTheHook() throws {
        guard #available(iOS 26.0, *) else { throw XCTSkip("native path needs iOS 26") }
        assertReassigningTheHeldEventDoesNotRerunTheHook(mode: .native)
    }

    func test_manualMode_aNewEventWithTheSamePayload_isTakenOnce() {
        assertANewEventWithTheSamePayloadIsTakenOnce(mode: .manual)
    }

    func test_nativeMode_aNewEventWithTheSamePayload_isTakenOnce() throws {
        guard #available(iOS 26.0, *) else { throw XCTSkip("native path needs iOS 26") }
        assertANewEventWithTheSamePayloadIsTakenOnce(mode: .native)
    }
}

// MARK: - A rebuilt controller

/// A controller created for a view model that outlived the previous controller skips the event the slot still holds,
/// in `setupView()`. Manual mode on a detached view, which lays out only when asked.
@available(iOS 17.0, *)
@MainActor
final class ViewEventCursorSkipTests: XCTestCase {

    private final class SlotViewController: BaseViewController {
        var source: EventSource?
        /// Whether `setupView()` skips the event the slot holds.
        var skipsHeldEvent = true
        private(set) var handled: [String] = []
        private(set) var passes: Int = .zero
        private var cursor = ViewEventCursor()

        override func setupView() {
            super.setupView()
            if skipsHeldEvent { cursor.skip(source?.event) }
        }

        override func updateContent() {
            super.updateContent()
            passes += 1
            if let payload = cursor.take(source?.event) { handled.append(payload) }
        }
    }

    override func tearDown() {
        ObservationMode.override = nil
        super.tearDown()
    }

    /// A controller for `source` that has run its first pass.
    private func makeRendered(_ source: EventSource, skipsHeldEvent: Bool = true) -> SlotViewController {
        ObservationMode.override = .manual
        let vc = SlotViewController()
        vc.source = source
        vc.skipsHeldEvent = skipsHeldEvent
        vc.loadViewIfNeeded()
        vc.view.frame = .init(x: .zero, y: .zero, width: 320, height: 480)
        vc.view.layoutIfNeeded()
        return vc
    }

    func test_aRebuiltController_doesNotActOnTheEventTheSlotStillHolds() {
        let source = EventSource()
        source.event = .init("saved")
        let earlier = makeRendered(source, skipsHeldEvent: false)
        XCTAssertEqual(earlier.handled, ["saved"])

        let withoutSkip = makeRendered(source, skipsHeldEvent: false)
        XCTAssertEqual(withoutSkip.handled, ["saved"], "without the skip, the rebuilt controller shows the event again")

        let rebuilt = makeRendered(source)
        XCTAssertEqual(rebuilt.passes, 1)
        XCTAssertEqual(rebuilt.handled, [])
    }

    func test_aRebuiltController_takesALaterEventOnce() {
        let source = EventSource()
        source.event = .init("saved")
        let rebuilt = makeRendered(source)

        source.event = .init("later")
        rebuilt.view.layoutIfNeeded()
        rebuilt.setNeedsContentUpdate()
        rebuilt.view.layoutIfNeeded()

        XCTAssertEqual(rebuilt.passes, 3)
        XCTAssertEqual(rebuilt.handled, ["later"])
    }

    func test_skippingAnEmptySlot_handsTheNextEventOverOnce() {
        let source = EventSource()
        let vc = makeRendered(source)

        source.event = .init("fired")
        vc.view.layoutIfNeeded()
        vc.setNeedsContentUpdate()
        vc.view.layoutIfNeeded()

        XCTAssertEqual(vc.passes, 3)
        XCTAssertEqual(vc.handled, ["fired"])
    }
}
