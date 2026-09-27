//
//  KeyWindowHostedTests.swift
//

import UIKit
import XCTest
import Common

/// The live key-window lookup. Hosted: only a running app has a connected, foreground-active window scene.
///
/// Read through `UIView.keyWindow`, which forwards to the application lookup: outside the module,
/// `UIApplication.shared.keyWindow` is ambiguous with UIKit's deprecated property of the same name.
@MainActor
final class KeyWindowHostedTests: XCTestCase {

    func test_keyWindow_isTheHostScenesKeyWindow() throws {
        let scene = try XCTUnwrap(
            UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first { $0.activationState == .foregroundActive },
            "the host app must have a foreground-active window scene"
        )
        let keyWindow = try XCTUnwrap(UIView().keyWindow)
        XCTAssertIdentical(keyWindow, scene.keyWindow)
        XCTAssertTrue(keyWindow.isKeyWindow)
        XCTAssertIdentical(UIApplication.shared.topMostView?.window, keyWindow)
    }
}
