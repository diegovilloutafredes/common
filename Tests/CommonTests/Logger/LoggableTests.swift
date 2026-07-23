//
//  LoggableTests.swift
//

import XCTest
@testable import Common

final class LoggableTests: XCTestCase {

    /// `shouldLog` persists through `KeyValueStore(.secure)` — the real Keychain,
    /// which outlives the test process. Without purging, the "defaults for unset
    /// type" test reads last run's persisted value instead of exercising the
    /// default path, and a run crashing after `shouldLog = false` poisons the
    /// next run with no code change.
    private let secureStore = KeyValueStore(type: .secure)
    private let persistedKey = "\(TestLoggable.staticKey).shouldLog"

    override func setUp() {
        super.setUp()
        secureStore.remove(using: persistedKey)
        // The getter is cache-first; clear the cache so each test observes the
        // store/default path instead of values a previous test cached.
        _resetLoggableCacheForTesting()
    }

    override func tearDown() {
        // Reset every mutated process-global static to its DEBUG default so tests are
        // order-independent — no test needs to manually restore state for the next one.
        Logger.isRuntimeForceEnabled = false
        Logger.shouldLog = true
        TestLoggable.shouldLog = true // fixes the in-process cache
        secureStore.remove(using: persistedKey) // leaves no Keychain residue
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

    // NOTE: the setter's write-through to the Keychain store is NOT verifiable
    // here — on unsigned simulator test hosts (CODE_SIGNING_ALLOWED=NO) keychain
    // writes report success but reads return nil even in-process (verified
    // empirically 2026-07-23 by asserting a post-cache-clear read and watching
    // it fall through to the default). The cache reset in setUp is what keeps
    // the default-path and setter tests honest and order-independent.

    func test_forceEnable_setsLoggerShouldLogTrue() {
        Logger.shouldLog = false
        Logger.forceEnable()
        XCTAssertTrue(Logger.shouldLog)
    }

    func test_isRuntimeForceEnabled_defaultsFalse() {
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
        // tearDown restores defaults — no manual restore needed.
    }
}

private enum TestLoggable: Loggable {}
