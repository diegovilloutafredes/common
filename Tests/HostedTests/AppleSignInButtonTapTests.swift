//
//  AppleSignInButtonTapTests.swift
//
//  Hosted lane: `UIControl.sendActions` routes through `UIApplication.shared`,
//  which is inert in the hostless CommonTests bundle — tap forwarding can only
//  be observed with a real host app.
//

import AuthenticationServices
import UIKit
import XCTest
import Common

@MainActor
final class AppleSignInButtonTapTests: XCTestCase {

    private func inner(of button: AppleSignInButton) throws -> ASAuthorizationAppleIDButton {
        try XCTUnwrap(button.subviews.compactMap { $0 as? ASAuthorizationAppleIDButton }.first)
    }

    // Characterization pin — protects the forwarding path through the rewrite.
    func test_tapOnInnerButton_firesOnTap() throws {
        let button = AppleSignInButton()
        var taps = 0
        button.onTap { taps += 1 }

        try inner(of: button).sendActions(for: .touchUpInside)

        XCTAssertEqual(taps, 1)
    }

    func test_disabled_doesNotForwardTaps() throws {
        let button = AppleSignInButton()
        var taps = 0
        button.onTap { taps += 1 }
        button.isEnabled = false

        try inner(of: button).sendActions(for: .touchUpInside)

        XCTAssertEqual(taps, 0, "a disabled button must not re-emit the inner tap")
    }

    func test_reEnabled_forwardsTapsAgain() throws {
        let button = AppleSignInButton()
        var taps = 0
        button.onTap { taps += 1 }
        button.isEnabled = false
        button.isEnabled = true

        try inner(of: button).sendActions(for: .touchUpInside)

        XCTAssertEqual(taps, 1)
    }
}
