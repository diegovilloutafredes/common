//
//  ReleaseGateTests.swift
//
//  Pins RELEASE-ONLY behavior — the `#else` branches of the compile gates,
//  which are exactly what tag-pinned consumers run via the Release-archived
//  XCFramework. In Debug builds every test here SKIPS (via the public
//  `Logger.isCompileTimeEnabled` pin); the `Common-ReleaseGates` scheme runs
//  them for real in CI with `ENABLE_TESTABILITY=YES` (symbol access only —
//  it does not define DEBUG, so the release branches stay active).
//

import XCTest
@testable import Common

final class ReleaseGateTests: XCTestCase {

    private let secureStore = KeyValueStore(type: .secure)
    private let loggerKey = "\(Logger.staticKey).shouldLog"

    /// Every test asserts behavior that only exists when DEBUG is undefined.
    private func skipUnlessRelease() throws {
        try XCTSkipIf(Logger.isCompileTimeEnabled, "Debug build — release gates are inactive; run via the Common-ReleaseGates scheme")
    }

    override func setUp() {
        super.setUp()
        secureStore.remove(using: loggerKey)
        _resetLoggableCacheForTesting()
    }

    override func tearDown() {
        Logger.printHandler = { print($0) }
        Logger.isRuntimeForceEnabled = false
        secureStore.remove(using: loggerKey)
        _resetLoggableCacheForTesting()
        super.tearDown()
    }

    func test_compileTimeGate_isOffInRelease() throws {
        try skipUnlessRelease()

        XCTAssertFalse(Logger.isCompileTimeEnabled, "the Release XCFramework must ship with the log gate compiled off")
    }

    func test_logging_isSilentByDefault_andRuntimeForceEnableTurnsItOn() throws {
        try skipUnlessRelease()

        var frames = [String]()
        Logger.printHandler = { frames.append($0) }

        // Default path: no stored value, no runtime override → silent.
        Logger.log("release-silence-probe")
        XCTAssertTrue(frames.isEmpty, "with the compile gate off and no runtime override, Logger.log must emit nothing")

        // The documented consumer escape hatch: flip the runtime override.
        Logger.isRuntimeForceEnabled(true)
        _resetLoggableCacheForTesting() // shouldLog is cache-first; the default must be re-derived
        Logger.log("release-forced-probe")

        XCTAssertEqual(frames.count, 1, "isRuntimeForceEnabled must re-enable emission in a Release build")
        XCTAssertTrue(frames[0].contains("release-forced-probe"))
    }

    func test_uiViewBuilder_ifWithoutElse_degradesToHiddenPlaceholder() throws {
        try skipUnlessRelease()

        // In Debug this path assertionFailure-traps by design — the graceful
        // placeholder is the release behavior under test.
        let placeholder = UIViewBuilder.buildOptional(nil)

        XCTAssertTrue(placeholder.isHidden, "the release fallback must be invisible")
        XCTAssertFalse(placeholder.isUserInteractionEnabled, "the release fallback must not intercept touches")
    }
}
