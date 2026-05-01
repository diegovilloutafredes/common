//
//  LoggableTests.swift
//

import XCTest
@testable import Common

final class LoggableTests: XCTestCase {

    func test_isCompileTimeEnabled_isTrueInTestTarget() {
        XCTAssertTrue(Logger.isCompileTimeEnabled)
    }

    func test_shouldLog_defaultsTrueForUnsetTypeInDebug() {
        XCTAssertTrue(TestLoggable.shouldLog)
    }

    func test_shouldLog_setterRoundtrips() {
        TestLoggable.shouldLog = false
        XCTAssertFalse(TestLoggable.shouldLog)
        TestLoggable.shouldLog = true
        XCTAssertTrue(TestLoggable.shouldLog)
    }

    func test_forceEnable_setsLoggerShouldLogTrue() {
        Logger.shouldLog = false
        Logger.forceEnable()
        XCTAssertTrue(Logger.shouldLog)
    }
}

private enum TestLoggable: Loggable {}
