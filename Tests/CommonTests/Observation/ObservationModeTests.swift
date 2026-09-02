//
//  ObservationModeTests.swift
//

import XCTest
@testable import Common

@MainActor
final class ObservationModeTests: XCTestCase {

    override func tearDown() {
        ObservationMode.override = nil
        super.tearDown()
    }

    func test_current_followsTheOSVersion() {
        if #available(iOS 26.0, *) {
            XCTAssertEqual(ObservationMode.current, .native)
        } else if #available(iOS 17.0, *) {
            XCTAssertEqual(ObservationMode.current, .manual)
        } else {
            XCTAssertEqual(ObservationMode.current, .unavailable)
        }
    }

    func test_override_winsOverOSDetection() {
        ObservationMode.override = .manual
        XCTAssertEqual(ObservationMode.current, .manual)
        ObservationMode.override = .unavailable
        XCTAssertEqual(ObservationMode.current, .unavailable)
    }

    func test_clearingOverride_restoresOSDetection() {
        ObservationMode.override = .unavailable
        ObservationMode.override = nil
        if #available(iOS 26.0, *) { XCTAssertEqual(ObservationMode.current, .native) }
    }
}
