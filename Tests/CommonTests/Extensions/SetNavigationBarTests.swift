//
//  SetNavigationBarTests.swift
//

import XCTest
@testable import Common

@MainActor
final class SetNavigationBarTests: XCTestCase {

    private let light = UITraitCollection(userInterfaceStyle: .light)

    private func appearances(of item: UINavigationItem) -> [UINavigationBarAppearance?] {
        [item.standardAppearance, item.scrollEdgeAppearance, item.compactAppearance, item.compactScrollEdgeAppearance]
    }

    /// The defect: styling went to the navigation controller's shared bar, so it leaked onto every other screen.
    func test_stylesOnlyTheCallingScreen() {
        let first = UIViewController(), second = UIViewController()
        let navigationController = UINavigationController(rootViewController: first)
        navigationController.pushViewController(second, animated: false)
        let barBackground = navigationController.navigationBar.standardAppearance.backgroundColor
        let barScrollEdge = navigationController.navigationBar.scrollEdgeAppearance

        second.setNavigationBar(backgroundColor: .red, titleColor: .white)

        for appearance in appearances(of: second.navigationItem) {
            XCTAssertEqual(appearance?.backgroundColor, .red)
            XCTAssertEqual(appearance?.titleTextAttributes[.foregroundColor] as? UIColor, .white)
        }
        XCTAssertEqual(navigationController.navigationBar.standardAppearance.backgroundColor, barBackground)
        XCTAssertIdentical(navigationController.navigationBar.scrollEdgeAppearance, barScrollEdge)
        XCTAssertTrue(appearances(of: first.navigationItem).allSatisfy { $0 == nil }, "the other screen keeps its own appearance")
    }

    func test_stylesAScreenBeforeItIsPushed() {
        let screen = UIViewController()
        screen.setNavigationBar(backgroundColor: .red)
        XCTAssertEqual(screen.navigationItem.standardAppearance?.backgroundColor, .red)
    }

    /// The system's bar hairline is the one an opaque configuration carries: from iOS 26 a default or transparent
    /// appearance has no shadow at all, so copying the default would draw nothing.
    func test_hasShadowTrue_showsTheSystemBarShadow() throws {
        let screen = UIViewController()
        screen.setNavigationBar(hasShadow: true)

        let opaque = UINavigationBarAppearance()
        opaque.configureWithOpaqueBackground()
        let expected = try XCTUnwrap(opaque.shadowColor).resolvedColor(with: light)
        let shadow = try XCTUnwrap(screen.navigationItem.standardAppearance?.shadowColor).resolvedColor(with: light)
        XCTAssertEqual(shadow, expected)
        XCTAssertGreaterThan(shadow.cgColor.alpha, 0)
    }

    /// `hasShadow` defaults to false, which is how a default call has always rendered.
    func test_defaultCall_showsNoShadow() throws {
        let screen = UIViewController()
        screen.setNavigationBar()

        let appearance = try XCTUnwrap(screen.navigationItem.standardAppearance)
        let alpha = appearance.shadowColor?.resolvedColor(with: light).cgColor.alpha ?? 0
        XCTAssertEqual(alpha, 0)
    }

    /// UIKit has no per-screen translucency, so this one option still sets the shared bar.
    func test_isTranslucent_setsTheSharedBar() {
        let screen = UIViewController()
        let navigationController = UINavigationController(rootViewController: screen)
        screen.setNavigationBar(isTranslucent: false)
        XCTAssertFalse(navigationController.navigationBar.isTranslucent)
    }
}
