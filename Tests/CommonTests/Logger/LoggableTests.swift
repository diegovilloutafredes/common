//
//  LoggableTests.swift
//

import XCTest
@testable import Common

final class LoggableTests: XCTestCase {

    override func tearDown() {
        Logger.isRuntimeForceEnabled = false
        super.tearDown()
    }

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

    func test_isRuntimeForceEnabled_defaultsFalse() {
        XCTAssertFalse(Logger.isRuntimeForceEnabled)
    }

    func test_isRuntimeForceEnabled_isMutable() {
        Logger.isRuntimeForceEnabled = true
        XCTAssertTrue(Logger.isRuntimeForceEnabled)
        Logger.isRuntimeForceEnabled = false
        XCTAssertFalse(Logger.isRuntimeForceEnabled)
    }

    /// Flipping the runtime flag must not interfere with the existing `shouldLog`
    /// path in DEBUG. Guards against an accidental `&&` (instead of `||`) in the gate.
    /// Ends with `shouldLog = true` to leave the default state for other tests.
    func test_isRuntimeForceEnabled_doesNotBreakShouldLogInDebug() {
        Logger.isRuntimeForceEnabled = true
        TestLoggable.shouldLog = false
        XCTAssertFalse(TestLoggable.shouldLog)
        TestLoggable.shouldLog = true
        XCTAssertTrue(TestLoggable.shouldLog)
    }

    // MARK: - Fluent setters

    func test_isRuntimeForceEnabled_fluentSetter_persists() {
        Logger.isRuntimeForceEnabled(true)
        XCTAssertTrue(Logger.isRuntimeForceEnabled)
        Logger.isRuntimeForceEnabled(false)
        XCTAssertFalse(Logger.isRuntimeForceEnabled)
    }

    func test_shouldLog_fluentSetter_persists() {
        TestLoggable.shouldLog(false)
        XCTAssertFalse(TestLoggable.shouldLog)
        TestLoggable.shouldLog(true)
        XCTAssertTrue(TestLoggable.shouldLog)
    }

    func test_fluentSetters_chain() {
        Logger.isRuntimeForceEnabled(true).shouldLog(false)
        XCTAssertTrue(Logger.isRuntimeForceEnabled)
        XCTAssertFalse(Logger.shouldLog)
        // restore for downstream tests
        Logger.shouldLog(true)
    }
}

private enum TestLoggable: Loggable {}
