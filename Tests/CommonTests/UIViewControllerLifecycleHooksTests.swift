//
//  UIViewControllerLifecycleHooksTests.swift
//

import XCTest
import UIKit
@testable import Common

@MainActor
final class UIViewControllerLifecycleHooksTests: XCTestCase {

    func test_onViewDidLoad_firesAfterFirstViewAccess() {
        let vc = UIViewController()
        var fired = false
        vc.onViewDidLoad { _ in fired = true }
        _ = vc.view
        XCTAssertTrue(fired)
    }

    func test_onViewWillAppear_firesOnAppearanceTransition() {
        let vc = UIViewController()
        var fired = false
        vc.onViewWillAppear { _ in fired = true }
        _ = vc.view
        vc.beginAppearanceTransition(true, animated: false)
        XCTAssertTrue(fired)
        vc.endAppearanceTransition()
    }

    func test_onViewDidAppear_firesAfterAppearanceTransitionCompletes() {
        let vc = UIViewController()
        var fired = false
        vc.onViewDidAppear { _ in fired = true }
        _ = vc.view
        vc.beginAppearanceTransition(true, animated: false)
        vc.endAppearanceTransition()
        XCTAssertTrue(fired)
    }

    func test_onViewWillDisappear_firesWhenLeaving() {
        let vc = UIViewController()
        var fired = false
        vc.onViewWillDisappear { _ in fired = true }
        _ = vc.view
        vc.beginAppearanceTransition(true, animated: false)
        vc.endAppearanceTransition()
        vc.beginAppearanceTransition(false, animated: false)
        XCTAssertTrue(fired)
        vc.endAppearanceTransition()
    }

    func test_onViewDidDisappear_firesAfterLeaveCompletes() {
        let vc = UIViewController()
        var fired = false
        vc.onViewDidDisappear { _ in fired = true }
        _ = vc.view
        vc.beginAppearanceTransition(true, animated: false)
        vc.endAppearanceTransition()
        vc.beginAppearanceTransition(false, animated: false)
        vc.endAppearanceTransition()
        XCTAssertTrue(fired)
    }

    func test_chaining_returnsSelfAndPreservesAllHooks() {
        let vc = UIViewController()
        var didLoadFired = false
        var willAppearFired = false
        let chained = vc
            .onViewDidLoad { _ in didLoadFired = true }
            .onViewWillAppear { _ in willAppearFired = true }
        XCTAssertTrue(chained === vc)
        _ = vc.view
        vc.beginAppearanceTransition(true, animated: false)
        XCTAssertTrue(didLoadFired)
        XCTAssertTrue(willAppearFired)
        vc.endAppearanceTransition()
    }

    func test_unhookedViewController_doesNotCrashOnLifecycle() {
        let vc = UIViewController()
        _ = vc.view
        vc.beginAppearanceTransition(true, animated: false)
        vc.endAppearanceTransition()
        vc.beginAppearanceTransition(false, animated: false)
        vc.endAppearanceTransition()
    }
}
