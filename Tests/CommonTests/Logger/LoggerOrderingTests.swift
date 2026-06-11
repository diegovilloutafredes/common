//
//  LoggerOrderingTests.swift
//

import XCTest
@testable import Common

final class LoggerOrderingTests: XCTestCase {

    /// Redirects stdout into a pipe for the duration of `block` and returns what was printed.
    private func captureStdout(_ block: () -> Void) -> String {
        let pipe = Pipe()
        let savedStdout = dup(STDOUT_FILENO)
        dup2(pipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)

        block()
        fflush(stdout)

        dup2(savedStdout, STDOUT_FILENO)
        close(savedStdout)
        pipe.fileHandleForWriting.closeFile()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? .empty
    }

    func test_log_printsItemsInCallSiteOrder() {
        // Keys chosen so call-site order differs from alphabetical order.
        let output = captureStdout {
            Logger.log(["zulu": "1", "alpha": "2", "mike": "3"])
        }

        guard
            let zulu = output.range(of: "zulu"),
            let alpha = output.range(of: "alpha"),
            let mike = output.range(of: "mike")
        else { return XCTFail("Expected all keys in output, got: \(output)") }

        XCTAssertLessThan(zulu.lowerBound, alpha.lowerBound, "call-site order should be preserved")
        XCTAssertLessThan(alpha.lowerBound, mike.lowerBound, "call-site order should be preserved")
    }

    func test_log_requestStyleOrdering() {
        let output = captureStdout {
            Logger.log(["request": "r", "response": "s", "error": "e"])
        }

        guard
            let request = output.range(of: "request"),
            let response = output.range(of: "response"),
            let error = output.range(of: "error")
        else { return XCTFail("Expected all keys in output, got: \(output)") }

        XCTAssertLessThan(request.lowerBound, response.lowerBound)
        XCTAssertLessThan(response.lowerBound, error.lowerBound)
    }

    func test_log_singleItem_printsUnderItemKey() {
        let output = captureStdout {
            Logger.log("plain message")
        }

        XCTAssertTrue(output.contains("item"), "Any overload should log under the 'item' key, got: \(output)")
        XCTAssertTrue(output.contains("plain message"))
    }
}
