//
//  LoggerOrderingTests.swift
//

import XCTest
@testable import Common

final class LoggerOrderingTests: XCTestCase {

    // Frames are captured through Logger's injectable sink — deterministic and
    // concurrency-safe, unlike the previous dup2 stdout hijack (which deadlocks
    // past the 64KB pipe buffer and races any other stdout writer).

    private let lock = NSLock()
    private var frames: [String] = []

    override func setUp() {
        super.setUp()
        frames = []
        Logger.printHandler = { [weak self] frame in
            guard let self else { return }
            self.lock.lock()
            self.frames.append(frame)
            self.lock.unlock()
        }
    }

    override func tearDown() {
        Logger.printHandler = { print($0) }
        super.tearDown()
    }

    private var capturedFrames: [String] {
        lock.lock()
        defer { lock.unlock() }
        return frames
    }

    func test_log_printsItemsInCallSiteOrder() {
        // Keys chosen so call-site order differs from alphabetical order.
        Logger.log(["zulu": "1", "alpha": "2", "mike": "3"])

        guard let output = capturedFrames.first else { return XCTFail("Expected one frame") }
        guard
            let zulu = output.range(of: "zulu"),
            let alpha = output.range(of: "alpha"),
            let mike = output.range(of: "mike")
        else { return XCTFail("Expected all keys in output, got: \(output)") }

        XCTAssertLessThan(zulu.lowerBound, alpha.lowerBound, "call-site order should be preserved")
        XCTAssertLessThan(alpha.lowerBound, mike.lowerBound, "call-site order should be preserved")
    }

    func test_log_singleItem_printsUnderItemKey() {
        Logger.log("plain message")

        guard let output = capturedFrames.first else { return XCTFail("Expected one frame") }
        // The composed line, not a loose substring: pins the key AND the
        // title/value formatting (a bare contains("item") also matches the
        // bundle id, key renames like "items", etc.).
        XCTAssertTrue(output.contains("🔸 item: plain message"),
                      "Any overload should log under the 'item' key, got: \(output)")
    }

    /// Pins the single-invocation frame-atomicity contract the logger commit
    /// introduced: concurrent logs arrive as one COMPLETE frame each — a revert
    /// to one print-per-line would deliver fragments here.
    func test_log_concurrentCalls_emitOneCompleteFramePerCall() {
        let logged = expectation(description: "all concurrent logs returned")
        logged.expectedFulfillmentCount = 20

        for index in 0..<20 {
            DispatchQueue.global().async {
                Logger.log(["index": "\(index)", "payload": "value-\(index)"])
                logged.fulfill()
            }
        }
        wait(for: [logged], timeout: 5)

        let all = capturedFrames
        XCTAssertEqual(all.count, 20, "exactly one sink invocation per log call")
        for frame in all {
            XCTAssertTrue(frame.contains("🎯"), "frame missing its top border: \(frame)")
            XCTAssertTrue(frame.contains("🔸 Caller"), "frame missing its caller line: \(frame)")
            XCTAssertTrue(frame.contains("🔸 index"), "frame missing its items: \(frame)")
            XCTAssertTrue(frame.contains("🔸 payload"), "frame arrived fragmented: \(frame)")
        }
    }
}
