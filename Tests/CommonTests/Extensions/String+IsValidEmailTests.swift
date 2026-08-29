//
//  String+IsValidEmailTests.swift
//

import XCTest
import Common

final class StringIsValidEmailTests: XCTestCase {

    // MARK: - Valid

    func test_plainAddress_isValid() {
        XCTAssertTrue("jane@example.com".isValidEmail)
    }

    func test_plusTagAndSubdomain_isValid() {
        XCTAssertTrue("jane.doe+tag@sub.example.co.uk".isValidEmail)
    }

    // MARK: - Invalid

    func test_noAtSign_isInvalid() {
        XCTAssertFalse("not-an-email".isValidEmail)
    }

    func test_mailtoPrefix_isInvalid() {
        XCTAssertFalse("mailto:jane@example.com".isValidEmail)
    }

    // The anchored detector match must span the whole string — an address
    // followed by anything else is not an address.
    func test_trailingText_isInvalid() {
        XCTAssertFalse("jane@example.com foo".isValidEmail)
    }

    func test_commaSeparatedList_isInvalid() {
        XCTAssertFalse("jane@example.com, bob@example.com".isValidEmail)
    }

    func test_trailingNewline_isInvalid() {
        XCTAssertFalse("jane@example.com\n".isValidEmail)
    }

    // Non-BMP scalars occupy two UTF-16 units; the match range must be built
    // from utf16.count, or the trailing scalar falls outside the checked range.
    func test_trailingEmoji_isInvalid() {
        XCTAssertFalse("jane@example.com😀".isValidEmail)
    }
}
