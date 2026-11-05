//
//  UIViewControllerIsVisibleTests.swift
//

import XCTest
@testable import Common

/// `isVisible`: whether the controller's view is in a window, read without loading the view.
@MainActor
final class UIViewControllerIsVisibleTests: XCTestCase {

    func test_isVisible_isFalse_beforeTheViewLoads() {
        let controller = UIViewController()

        XCTAssertFalse(controller.isVisible)
        XCTAssertFalse(controller.isViewLoaded, "reading isVisible must not load the view")
    }

    func test_isVisible_isFalse_onceLoaded_outsideAWindow() {
        let controller = UIViewController()
        controller.loadViewIfNeeded()

        XCTAssertFalse(controller.isVisible)
    }

    func test_isVisible_isTrue_inAWindow() {
        let controller = UIViewController()
        let window = UIWindow(frame: .init(x: 0, y: 0, width: 320, height: 640))
        window.rootViewController = controller
        window.makeKeyAndVisible()
        defer { window.isHidden = true }

        XCTAssertTrue(controller.isVisible)
    }
}
