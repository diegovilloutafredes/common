//
//  AlertTitlesHostedTests.swift
//

import UIKit
import XCTest
import Common

/// Button titles on the standard alert. Hosted: the alert is presented from the host app's top-most controller.
@MainActor
final class AlertTitlesHostedTests: XCTestCase {

    /// Off screen: its alerts are presented from the host app's top-most controller.
    private let presenter = UIViewController()

    override func setUp() async throws {
        try await super.setUp()
        UIView.setAnimationsEnabled(false)
    }

    override func tearDown() async throws {
        if let alert = UIApplication.shared.topMostViewController as? UIAlertController {
            let dismissed = expectation(description: "the alert is dismissed")
            alert.dismiss(animated: false) { dismissed.fulfill() }
            await fulfillment(of: [dismissed], timeout: transitionTimeout)
        }
        UIView.setAnimationsEnabled(true)
        try await super.tearDown()
    }

    func test_customTitles_appearOnTheActionsInOrder_withTheirStyles() throws {
        presenter.presentAlertView(
            type: .customAlert(title: "Directions", message: "Open the map?"),
            acceptTitle: "Get directions",
            cancelTitle: "Not now",
            acceptAction: { _ in },
            cancelAction: { _ in }
        )

        let alert = try presentedAlert()
        XCTAssertEqual(alert.actions.map(\.title), ["Get directions", "Not now"])
        XCTAssertEqual(alert.actions.map(\.style), [.default, .cancel])
    }

    func test_existingCall_showsTheDefaultTitles() throws {
        presenter.presentAlertView(type: .genericError, acceptAction: nil, cancelAction: { _ in })

        let alert = try presentedAlert()
        XCTAssertEqual(alert.actions.map(\.title), [String.DefaultValues.Alerts.acceptActionTitle, String.DefaultValues.Alerts.cancelActionTitle])
    }

    func test_withoutACancelAction_thereIsNoCancelButton() throws {
        presenter.presentAlertView(type: .genericError, acceptTitle: "Got it", cancelTitle: "Not now")

        let alert = try presentedAlert()
        XCTAssertEqual(alert.actions.map(\.title), ["Got it"])
    }

    private func presentedAlert() throws -> UIAlertController {
        try XCTUnwrap(UIApplication.shared.topMostViewController as? UIAlertController, "the alert is on screen")
    }
}
