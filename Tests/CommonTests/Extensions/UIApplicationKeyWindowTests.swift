//
//  UIApplicationKeyWindowTests.swift
//

import XCTest
@testable import Common

/// Key-window resolution across scene activation states. Real scenes can't be put into a given state in a test, so the
/// ranking is exercised through (activation state, key window) pairs; `KeyWindowHostedTests` covers the live path.
@MainActor
final class UIApplicationKeyWindowTests: XCTestCase {

    private func window() -> UIWindow { UIWindow(frame: .init(x: 0, y: 0, width: 320, height: 640)) }

    func test_activeScene_isPreferredOverInactiveScene() {
        let inactive = window(), active = window()
        let resolved = UIApplication.preferredKeyWindow(among: [
            (activationState: .foregroundInactive, keyWindow: inactive),
            (activationState: .foregroundActive, keyWindow: active)
        ])
        XCTAssertIdentical(resolved, active)
    }

    /// The defect: launch, permission prompts, Face ID and Control Center leave the only scene foreground-inactive,
    /// and the lookup used to return nil, silently dropping alerts, snackbars and toasts.
    func test_inactiveOnlyScene_returnsItsKeyWindow() {
        let inactive = window()
        let resolved = UIApplication.preferredKeyWindow(among: [(activationState: .foregroundInactive, keyWindow: inactive)])
        XCTAssertIdentical(resolved, inactive)
    }

    func test_otherStates_areTheLastResort() {
        let background = window(), unattached = window(), inactive = window()
        XCTAssertIdentical(
            UIApplication.preferredKeyWindow(among: [(activationState: .background, keyWindow: background)]),
            background
        )
        XCTAssertIdentical(
            UIApplication.preferredKeyWindow(among: [
                (activationState: .unattached, keyWindow: unattached),
                (activationState: .foregroundInactive, keyWindow: inactive)
            ]),
            inactive
        )
    }

    func test_sceneWithoutKeyWindow_isSkipped() {
        let inactive = window()
        let resolved = UIApplication.preferredKeyWindow(among: [
            (activationState: .foregroundActive, keyWindow: nil),
            (activationState: .foregroundInactive, keyWindow: inactive)
        ])
        XCTAssertIdentical(resolved, inactive)
    }

    func test_noKeyWindowAnywhere_returnsNil() {
        XCTAssertNil(UIApplication.preferredKeyWindow(among: []))
        XCTAssertNil(UIApplication.preferredKeyWindow(among: [(activationState: .foregroundActive, keyWindow: nil)]))
    }

    /// Among scenes in the same state, the app's current key window wins, as the scene-less lookup it replaces did.
    func test_sameState_prefersTheAppKeyWindow() {
        let other = window(), key = window()
        key.makeKeyAndVisible()
        defer { key.isHidden = true }
        XCTAssertTrue(key.isKeyWindow, "precondition: the window must be the app's key window")

        let resolved = UIApplication.preferredKeyWindow(among: [
            (activationState: .foregroundActive, keyWindow: other),
            (activationState: .foregroundActive, keyWindow: key)
        ])
        XCTAssertIdentical(resolved, key)
    }
}
