//
//  UIViewControllerLifecycleHooksTests.swift
//

import XCTest
import UIKit
@testable import Common

@MainActor
final class UIViewControllerLifecycleHooksTests: XCTestCase {

    // Every test counts firings (not a boolean) so the canonical swizzling
    // regression — a hook firing twice per event after a bad double
    // method_exchangeImplementations — cannot hide behind `fired == true`.

    func test_onViewDidLoad_firesOnceWithTheViewController() {
        let vc = UIViewController()
        var fireCount = 0
        var receivedVC: UIViewController?
        vc.onViewDidLoad { receivedVC = $0; fireCount += 1 }

        _ = vc.view

        XCTAssertEqual(fireCount, 1)
        XCTAssertTrue(receivedVC === vc, "the hook must receive the VC it was registered on")
    }

    func test_onViewWillAppear_firesOnceOnAppearanceTransition() {
        let vc = UIViewController()
        var fireCount = 0
        var receivedVC: UIViewController?
        vc.onViewWillAppear { receivedVC = $0; fireCount += 1 }

        _ = vc.view
        vc.beginAppearanceTransition(true, animated: false)

        XCTAssertEqual(fireCount, 1)
        XCTAssertTrue(receivedVC === vc)
        vc.endAppearanceTransition()
    }

    func test_onViewDidAppear_firesOnceAfterAppearanceTransitionCompletes() {
        let vc = UIViewController()
        var fireCount = 0
        var receivedVC: UIViewController?
        vc.onViewDidAppear { receivedVC = $0; fireCount += 1 }

        _ = vc.view
        vc.beginAppearanceTransition(true, animated: false)
        vc.endAppearanceTransition()

        XCTAssertEqual(fireCount, 1)
        XCTAssertTrue(receivedVC === vc)
    }

    func test_onViewWillDisappear_firesOnceWhenLeaving() {
        let vc = UIViewController()
        var fireCount = 0
        var receivedVC: UIViewController?
        vc.onViewWillDisappear { receivedVC = $0; fireCount += 1 }

        _ = vc.view
        vc.beginAppearanceTransition(true, animated: false)
        vc.endAppearanceTransition()
        vc.beginAppearanceTransition(false, animated: false)

        XCTAssertEqual(fireCount, 1)
        XCTAssertTrue(receivedVC === vc)
        vc.endAppearanceTransition()
    }

    func test_onViewDidDisappear_firesOnceAfterLeaveCompletes() {
        let vc = UIViewController()
        var fireCount = 0
        var receivedVC: UIViewController?
        vc.onViewDidDisappear { receivedVC = $0; fireCount += 1 }

        _ = vc.view
        vc.beginAppearanceTransition(true, animated: false)
        vc.endAppearanceTransition()
        vc.beginAppearanceTransition(false, animated: false)
        vc.endAppearanceTransition()

        XCTAssertEqual(fireCount, 1)
        XCTAssertTrue(receivedVC === vc)
    }

    func test_chaining_returnsSelfAndPreservesAllHooks() {
        let vc = UIViewController()
        var didLoadCount = 0
        var willAppearCount = 0
        let chained = vc
            .onViewDidLoad { _ in didLoadCount += 1 }
            .onViewWillAppear { _ in willAppearCount += 1 }
        XCTAssertTrue(chained === vc)

        _ = vc.view
        vc.beginAppearanceTransition(true, animated: false)

        XCTAssertEqual(didLoadCount, 1)
        XCTAssertEqual(willAppearCount, 1)
        vc.endAppearanceTransition()
    }

    /// Production VCs are subclasses with their own lifecycle overrides — the
    /// swizzle intercepts UIViewController's IMP, so the hook fires during the
    /// override's `super.viewDidLoad()` call, exactly once. This pins both the
    /// once-ness and the ordering of that dispatch chain.
    func test_subclassOverride_hookFiresOnceDuringSuperCall() {
        class OverridingViewController: UIViewController {
            var record: [String] = []
            override func viewDidLoad() {
                record.append("override-before-super")
                super.viewDidLoad()
                record.append("override-after-super")
            }
        }

        let vc = OverridingViewController()
        vc.onViewDidLoad { _ in vc.record.append("hook") }

        _ = vc.view

        XCTAssertEqual(vc.record, ["override-before-super", "hook", "override-after-super"],
                       "the hook must fire exactly once, inside the override's super.viewDidLoad() call")
    }

    /// Swizzling is process-global: force the swizzle install (by hooking a
    /// throwaway VC) BEFORE exercising the unhooked one, so this test verifies
    /// the swizzled path tolerates hookless VCs regardless of execution order —
    /// previously it only did so because 'u' sorts after the other test names.
    func test_unhookedViewController_doesNotCrashOnLifecycle() {
        UIViewController().onViewDidLoad { _ in } // installs the swizzles

        let vc = UIViewController()
        _ = vc.view
        vc.beginAppearanceTransition(true, animated: false)
        vc.endAppearanceTransition()
        vc.beginAppearanceTransition(false, animated: false)
        vc.endAppearanceTransition()
    }
}
