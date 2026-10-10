//
//  String+Base64Tests.swift
//

import XCTest
import Common

final class StringBase64Tests: XCTestCase {

    func test_encodedAsBase64_encodesTheUTF8Bytes() {
        XCTAssertEqual("canción".encodedAsBase64, "Y2FuY2nDs24=")
    }

    func test_decodedFromBase64_returnsTheEncodedText() {
        XCTAssertEqual("Y2FuY2nDs24=".decodedFromBase64, "canción")
    }
}
