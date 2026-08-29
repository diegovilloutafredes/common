//
//  AppleSignInButtonTests.swift
//

import AuthenticationServices
import UIKit
import XCTest
@testable import Common

@MainActor
final class AppleSignInButtonTests: XCTestCase {

    private var windows: [UIWindow] = []

    override func tearDown() async throws {
        windows.forEach { $0.isHidden = true }
        windows = []
    }

    private func inner(of button: AppleSignInButton) throws -> ASAuthorizationAppleIDButton {
        try XCTUnwrap(button.subviews.compactMap { $0 as? ASAuthorizationAppleIDButton }.first)
    }

    /// Trait changes propagate through the view hierarchy — the button must be
    /// hosted in a window for `overrideUserInterfaceStyle` to reach it.
    private func hosted(_ button: AppleSignInButton, appearance: UIUserInterfaceStyle) -> AppleSignInButton {
        let window = UIWindow(frame: .init(x: 0, y: 0, width: 200, height: 100))
        window.overrideUserInterfaceStyle = appearance
        window.makeKeyAndVisible()
        window.addSubview(button)
        windows.append(window)
        return button
    }

    /// Flips the hosting window's appearance. Trait propagation from the window
    /// runs on the UIKit update cycle — give it one pass (no layout on the button).
    private func flip(_ button: AppleSignInButton, to appearance: UIUserInterfaceStyle) {
        button.window?.overrideUserInterfaceStyle = appearance
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))
        XCTAssertEqual(button.traitCollection.userInterfaceStyle, appearance,
                       "precondition: the trait must reach the button before the hook can be judged")
    }

    // MARK: - Configuration

    func test_init_storesType() {
        XCTAssertEqual(AppleSignInButton(type: .continue).authorizationButtonType, .continue)
        XCTAssertEqual(AppleSignInButton().authorizationButtonType, .default)
    }

    func test_explicitStyle_resolvesToItself() {
        XCTAssertEqual(AppleSignInButton(style: .black).resolvedStyle, .black)
        XCTAssertEqual(AppleSignInButton(style: .whiteOutline).resolvedStyle, .whiteOutline)
    }

    // MARK: - isEnabled

    func test_disabled_propagatesToInnerButton() throws {
        let button = AppleSignInButton()

        button.isEnabled = false

        XCTAssertFalse(try inner(of: button).isEnabled)
    }

    // MARK: - Accessibility

    func test_accessibilityLabel_forwardsInnerButtonLabel() throws {
        let button = AppleSignInButton()
        let innerLabel = try XCTUnwrap(try inner(of: button).accessibilityLabel)

        XCTAssertEqual(button.accessibilityLabel, innerLabel)
        XCTAssertTrue(button.isAccessibilityElement)
    }

    func test_accessibilityLabel_explicitValueWins() throws {
        let button = AppleSignInButton()

        button.accessibilityLabel = "Custom"

        XCTAssertEqual(button.accessibilityLabel, "Custom")
    }

    // MARK: - Sizing

    func test_intrinsicContentSize_matchesInnerButton() throws {
        let button = AppleSignInButton()

        XCTAssertEqual(button.intrinsicContentSize, try inner(of: button).intrinsicContentSize)
    }

    // MARK: - Adaptive style

    func test_adaptiveStyle_isBlackInLightAppearance() {
        let button = hosted(AppleSignInButton(), appearance: .light)

        XCTAssertEqual(button.resolvedStyle, .black)
    }

    func test_adaptiveStyle_isWhiteInDarkAppearance() {
        let button = hosted(AppleSignInButton(), appearance: .dark)

        XCTAssertEqual(button.resolvedStyle, .white)
    }

    func test_adaptiveStyle_rebuildsInnerButtonOnAppearanceFlip() throws {
        let button = hosted(AppleSignInButton(), appearance: .light)
        let before = try inner(of: button)

        flip(button, to: .dark)

        XCTAssertEqual(button.resolvedStyle, .white)
        XCTAssertTrue(try inner(of: button) !== before, "the Apple button's style is init-only; a flip must rebuild it")
    }

    func test_adaptiveStyle_rebuildPreservesDisabledState() throws {
        let button = hosted(AppleSignInButton(), appearance: .light)
        button.isEnabled = false

        flip(button, to: .dark)

        XCTAssertFalse(try inner(of: button).isEnabled)
    }

    func test_explicitStyle_ignoresAppearanceFlip() throws {
        let button = hosted(AppleSignInButton(style: .whiteOutline), appearance: .light)
        let before = try inner(of: button)

        flip(button, to: .dark)

        XCTAssertEqual(button.resolvedStyle, .whiteOutline)
        XCTAssertTrue(try inner(of: button) === before)
    }
}
