//
//  ViewEventTests.swift
//

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
}
