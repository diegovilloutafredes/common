//
//  String+RUTUtilitiesTests.swift
//

import XCTest
import Common

// MARK: - Verified RUT fixtures (Módulo 11 computed by hand)
//
//  "11.111.111-1"  → sum=32,  11-(32%11)=1   → digit 1
//  "12.345.678-5"  → sum=138, 11-(138%11)=5  → digit 5
//  "76.354.771-K"  → sum=155, 11-(155%11)=10 → digit K
//  "1.111.119-K"   → sum=45,  11-(45%11)=10  → digit K
//  "2.222.226-0"   → sum=66,  11-(66%11)=11  → digit 0
//  "9.999.999-3"   → sum=261, 11-(261%11)=3  → digit 3
//  "123.456.789-2" → sum=174, 11-(174%11)=2  → digit 2
//  "1.234.567-4"   → sum=106, 11-(106%11)=4  → digit 4  (minimum-length fixture)
//
//  Dot separator in formatAsRUT output ("12.345.678-5") comes from the es_CL locale
//  hardcoded in Int.asDecimalNumber — not from user locale.

final class StringRUTUtilitiesTests: XCTestCase {

    // MARK: - isRUT — Valid: fully formatted

    func test_isRUT_formatted_digit5() {
        // Also the length-guard regression fixture: 12 chars raw — old code
        // checked count on the UNSTRIPPED string against the <= 10 guard and
        // rejected every fully formatted RUT.
        XCTAssertTrue("12.345.678-5".isRUT)
    }

    // MARK: - isRUT — Valid: stripped (digits + verifying char only)

    func test_isRUT_stripped_digitK() {
        XCTAssertTrue("76354771K".isRUT)
    }

    func test_isRUT_stripped_digitK_lowercase() {
        XCTAssertTrue("76354771k".isRUT)
    }

    func test_isRUT_stripped_digit0() {
        XCTAssertTrue("22222260".isRUT)
    }

    // MARK: - isRUT — Valid: hyphen only (no dots)

    func test_isRUT_hyphenOnly_digit5() {
        XCTAssertTrue("12345678-5".isRUT)
    }

    // MARK: - isRUT — Boundary

    func test_isRUT_boundary_minimumLength_8charsStripped() {
        // 8-char stripped = 7-digit number + verifying digit (distinct from other fixtures)
        XCTAssertTrue("12345674".isRUT)  // "1.234.567-4"
    }

    func test_isRUT_boundary_maximumLength_10charsStripped() {
        // 10-char stripped = 9-digit number + verifying digit
        XCTAssertTrue("1234567892".isRUT)  // "123.456.789-2"
    }

    func test_isRUT_boundary_7charsStripped_tooShort() {
        XCTAssertFalse("1234567".isRUT)
    }

    func test_isRUT_boundary_11charsStripped_tooLong() {
        XCTAssertFalse("12345678901".isRUT)
    }

    // MARK: - isRUT — Invalid

    func test_isRUT_empty() {
        XCTAssertFalse("".isRUT)
    }

    func test_isRUT_singleChar() {
        XCTAssertFalse("1".isRUT)
    }

    func test_isRUT_wrongVerifyingDigit_numericExpected() {
        // Correct digit for 12345678 is 5; 0 is wrong
        XCTAssertFalse("12.345.678-0".isRUT)
    }

    func test_isRUT_wrongVerifyingDigit_kExpected_gotNumeric() {
        // Correct digit for 76354771 is K; 5 is wrong
        XCTAssertFalse("76.354.771-5".isRUT)
    }

    func test_isRUT_wrongVerifyingDigit_zeroExpected_gotOne() {
        // Correct digit for 2222226 is 0; 1 is wrong
        XCTAssertFalse("2.222.226-1".isRUT)
    }

    func test_isRUT_nonNumericBody() {
        XCTAssertFalse("ABCDEFGH1".isRUT)
    }

    func test_isRUT_arbitraryString() {
        XCTAssertFalse("not-a-rut".isRUT)
    }

    func test_isRUT_leadingWhitespace() {
        // removeRUTFormat strips only "." and "-"; space is not removed, regex rejects it
        XCTAssertFalse(" 12345678-5".isRUT)
    }

    func test_isRUT_trailingNewline() {
        XCTAssertFalse("12345678-5\n".isRUT)
    }

    func test_isRUT_commaThousandSeparator() {
        // Comma is not a recognized separator; regex rejects it
        XCTAssertFalse("12,345,678-5".isRUT)
    }

    // Edge: all-zero RUT is algorithmically valid (sum=0, digit="0")
    // but is not a real assigned RUT — documents algorithm behavior explicitly.
    func test_isRUT_allZeros_algorithmicallyValid() {
        XCTAssertTrue("00000000".isRUT)
    }

    // MARK: - formatAsRUT — onlyIfValid: true (default)

    func test_formatAsRUT_stripped_digit5() {
        XCTAssertEqual("123456785".formatAsRUT(), "12.345.678-5")
    }

    func test_formatAsRUT_stripped_digitK_lowercaseInput() {
        // Verifying digit is normalized to uppercase in output
        XCTAssertEqual("76354771k".formatAsRUT(), "76.354.771-K")
    }

    func test_formatAsRUT_stripped_sevenDigitNumber() {
        XCTAssertEqual("99999993".formatAsRUT(), "9.999.999-3")
    }

    func test_formatAsRUT_stripped_nineDigitNumber() {
        XCTAssertEqual("1234567892".formatAsRUT(), "123.456.789-2")
    }

    func test_formatAsRUT_partiallyFormatted_hyphenOnly() {
        XCTAssertEqual("12345678-5".formatAsRUT(), "12.345.678-5")
    }

    func test_formatAsRUT_alreadyFormatted() {
        XCTAssertEqual("12.345.678-5".formatAsRUT(), "12.345.678-5")
    }

    // Regression: outer-self bug — formatted input used unstripped rutComponents,
    // producing number = "12.345.678-" → asInt → nil → returned stripped string "123456785".
    func test_formatAsRUT_regression_formattedInput_notReturnedAsStripped() {
        XCTAssertEqual("12.345.678-5".formatAsRUT(), "12.345.678-5")
        XCTAssertNotEqual("12.345.678-5".formatAsRUT(), "123456785")  // the specific wrong value the bug produced
    }

    func test_formatAsRUT_regression_formattedKInput() {
        XCTAssertEqual("76.354.771-K".formatAsRUT(), "76.354.771-K")
    }

    func test_formatAsRUT_invalidRUT_returnsSelf() {
        // Wrong verifying digit → not a valid RUT → returns self unchanged
        XCTAssertEqual("12.345.678-0".formatAsRUT(), "12.345.678-0")
    }

    func test_formatAsRUT_strippedInvalidRUT_returnsSelfUnformatted() {
        // A STRIPPED invalid body: with the validation guard dropped this would
        // come back formatted ("12.345.678-0"). The already-formatted invalid
        // fixture above cannot tell "refused to format" from "formatted anyway".
        XCTAssertEqual("123456780".formatAsRUT(), "123456780")
    }

    func test_formatAsRUT_arbitraryString_returnsSelf() {
        XCTAssertEqual("invalid".formatAsRUT(), "invalid")
    }

    func test_formatAsRUT_empty_returnsSelf() {
        XCTAssertEqual("".formatAsRUT(), "")
    }

    // MARK: - formatAsRUT — onlyIfValid: false

    func test_formatAsRUT_onlyIfValidFalse_validRUT() {
        XCTAssertEqual("123456785".formatAsRUT(onlyIfValid: false), "12.345.678-5")
    }

    func test_formatAsRUT_onlyIfValidFalse_formattedInput() {
        // Exercises the onlyIfValid:false path with a formatted input — highest-value
        // regression case since the outer-self bug was triggered by formatted inputs.
        XCTAssertEqual("12.345.678-5".formatAsRUT(onlyIfValid: false), "12.345.678-5")
    }

    func test_formatAsRUT_onlyIfValidFalse_wrongVerifyingDigit_stillFormats() {
        // Formats the number structure regardless of algorithm correctness
        XCTAssertEqual("123456780".formatAsRUT(onlyIfValid: false), "12.345.678-0")
    }

    func test_formatAsRUT_onlyIfValidFalse_twoCharInput() {
        // "19" → rutComponents = ("1","9") → "1".asInt=1 → "1" (no separator) → "1-9"
        XCTAssertEqual("19".formatAsRUT(onlyIfValid: false), "1-9")
    }

    func test_formatAsRUT_onlyIfValidFalse_singleChar_returnsSelf() {
        // count = 1, not > 1 → rutComponents returns (.empty, .empty) → asInt nil → self
        XCTAssertEqual("1".formatAsRUT(onlyIfValid: false), "1")
    }

    func test_formatAsRUT_onlyIfValidFalse_empty_returnsSelf() {
        XCTAssertEqual("".formatAsRUT(onlyIfValid: false), "")
    }

    // MARK: - removeRUTFormat

    func test_removeRUTFormat_fullyFormatted() {
        XCTAssertEqual("12.345.678-5".removeRUTFormat(), "123456785")
    }

    func test_removeRUTFormat_fullyFormattedWithK() {
        XCTAssertEqual("76.354.771-K".removeRUTFormat(), "76354771K")
    }

    func test_removeRUTFormat_alreadyStripped_noChange() {
        XCTAssertEqual("123456785".removeRUTFormat(), "123456785")
    }

    func test_removeRUTFormat_nineDigitRUT() {
        XCTAssertEqual("123.456.789-2".removeRUTFormat(), "1234567892")
    }

    func test_removeRUTFormat_empty() {
        XCTAssertEqual("".removeRUTFormat(), "")
    }

    func test_removeRUTFormat_onlyFormattingChars() {
        XCTAssertEqual("...-".removeRUTFormat(), "")
    }
}
