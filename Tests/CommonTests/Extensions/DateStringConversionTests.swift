//
//  DateStringConversionTests.swift
//

import XCTest
@testable import Common

/// Pins the behavior of `String.asDate(with:locale:)` and `Date.toString(with:)`:
/// es_CL locale by default, nil on format mismatch, and stable results across
/// the internal NSCache formatter reuse. All inputs are fixed strings/components —
/// no "now" — so results are deterministic on any CI timezone.
final class DateStringConversionTests: XCTestCase {

    func test_parseThenFormat_roundTrips() {
        let date = "2026-06-10".asDate(with: "yyyy-MM-dd")
        XCTAssertEqual(date?.toString(with: "yyyy-MM-dd"), "2026-06-10")
    }

    func test_parsedComponents_matchInput() {
        guard let date = "2026-06-10 15:30".asDate(with: "yyyy-MM-dd HH:mm")
        else { return XCTFail("Expected parse to succeed") }

        // The formatter has no explicit timeZone, so components are in the
        // current calendar's zone — same zone the formatter parsed in.
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        XCTAssertEqual(components.year, 2026)
        XCTAssertEqual(components.month, 6)
        XCTAssertEqual(components.day, 10)
        XCTAssertEqual(components.hour, 15)
        XCTAssertEqual(components.minute, 30)

        // The explicit expected Date pins the current-zone contract in EVERY
        // region: a formatter accidentally pinned to UTC passes the component
        // checks on a UTC CI host but fails this equality everywhere.
        let expected = Calendar.current.date(
            from: DateComponents(year: 2026, month: 6, day: 10, hour: 15, minute: 30)
        )
        XCTAssertEqual(date, expected)
    }

    func test_mismatchedFormat_returnsNil() {
        XCTAssertNil("10/06/2026".asDate(with: "yyyy-MM-dd"))
    }

    func test_garbageInput_returnsNil() {
        XCTAssertNil("not a date".asDate(with: "yyyy-MM-dd"))
    }

    func test_toString_usesSpanishChileanLocaleByDefault() {
        guard let date = "2026-06-10".asDate(with: "yyyy-MM-dd")
        else { return XCTFail("Expected parse to succeed") }

        XCTAssertEqual(date.toString(with: "MMMM").lowercased(), "junio")
    }

    func test_asDate_honorsExplicitLocale() {
        let pattern = "d MMMM yyyy"
        XCTAssertNotNil("10 June 2026".asDate(with: pattern, locale: .init(identifier: "en_US")))
        XCTAssertNil("10 June 2026".asDate(with: pattern, locale: .init(identifier: "es_CL")))
        XCTAssertNotNil("10 junio 2026".asDate(with: pattern, locale: .init(identifier: "es_CL")))
    }

    func test_repeatedParse_returnsEqualDates_acrossFormatterCache() {
        let first = "2026-06-10".asDate(with: "yyyy-MM-dd")
        let second = "2026-06-10".asDate(with: "yyyy-MM-dd")
        XCTAssertNotNil(first)
        XCTAssertEqual(first, second)
    }
}
