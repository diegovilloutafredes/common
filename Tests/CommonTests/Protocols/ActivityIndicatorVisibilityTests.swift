//
//  ActivityIndicatorVisibilityTests.swift
//

import UIKit
import XCTest
@testable import Common

/// `setActivityIndicator(visible:)` is the state-driven counterpart of start/stop, meant to be
/// called from `updateContent()` on every pass — so it must be idempotent in both directions.
@MainActor
final class ActivityIndicatorVisibilityTests: XCTestCase {

    private var window: UIWindow!

    override func setUp() {
        super.setUp()
        window = UIWindow(frame: .init(x: .zero, y: .zero, width: 320, height: 480))
        window.isHidden = false
    }

    override func tearDown() {
        window.isHidden = true
        window = nil
        super.tearDown()
    }

    private func spinnerBarItems(_ vc: UIViewController) -> Int {
        vc.navigationItem.rightBarButtonItems?.filter { $0.customView is UIActivityIndicatorView }.count ?? .zero
    }

    private func spinnerSubviews(_ vc: UIViewController) -> Int {
        vc.view.subviews.filter { $0 is UIActivityIndicatorView }.count
    }

    func test_navigationBar_visibleTwice_installsOneSpinner_andHiddenTwice_removesIt() {
        let vc = UIViewController()
        let nav = UINavigationController(rootViewController: vc)
        window.rootViewController = nav
        vc.loadViewIfNeeded()

        XCTAssertFalse(vc.isShowingActivityIndicator)
        vc.setActivityIndicator(visible: true)
        vc.setActivityIndicator(visible: true)
        XCTAssertTrue(vc.isShowingActivityIndicator)
        XCTAssertEqual(spinnerBarItems(vc), 1)

        vc.setActivityIndicator(visible: false)
        vc.setActivityIndicator(visible: false)
        XCTAssertFalse(vc.isShowingActivityIndicator)
        XCTAssertEqual(spinnerBarItems(vc), .zero)
    }

    func test_withoutNavigationBar_usesTheCenteredSubview_idempotently() {
        let vc = UIViewController()
        window.rootViewController = vc
        vc.loadViewIfNeeded()

        vc.setActivityIndicator(visible: true)
        vc.setActivityIndicator(visible: true)
        XCTAssertTrue(vc.isShowingActivityIndicator)
        XCTAssertEqual(spinnerSubviews(vc), 1)

        vc.setActivityIndicator(visible: false)
        XCTAssertFalse(vc.isShowingActivityIndicator)
        XCTAssertEqual(spinnerSubviews(vc), .zero)
    }

    func test_visibleTrue_keepsExistingBarItems() {
        let vc = UIViewController()
        let nav = UINavigationController(rootViewController: vc)
        window.rootViewController = nav
        vc.loadViewIfNeeded()
        let existing = UIBarButtonItem(title: "Edit", style: .plain, target: nil, action: nil)
        vc.navigationItem.rightBarButtonItems = [existing]

        vc.setActivityIndicator(visible: true)
        XCTAssertTrue(vc.navigationItem.rightBarButtonItems?.contains(existing) ?? false)
        XCTAssertEqual(spinnerBarItems(vc), 1)

        vc.setActivityIndicator(visible: false)
        XCTAssertEqual(vc.navigationItem.rightBarButtonItems?.count, 1)
        XCTAssertTrue(vc.navigationItem.rightBarButtonItems?.first === existing)
    }
}
