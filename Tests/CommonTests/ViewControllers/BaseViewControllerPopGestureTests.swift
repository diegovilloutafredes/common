//
//  BaseViewControllerPopGestureTests.swift
//

import XCTest
@testable import Common

/// `BaseViewController` as a gesture delegate: the swipe-back rule applies to the navigation controller's pop gesture
/// only, and screens can override it.
@MainActor
final class BaseViewControllerPopGestureTests: XCTestCase {

    private final class SwipeBackBlockingViewController: BaseViewController {
        override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            gestureRecognizer === navigationController?.interactivePopGestureRecognizer ? false : super.gestureRecognizerShouldBegin(gestureRecognizer)
        }
    }

    /// The defect: the controller refused every recognizer it was the delegate of while it was the only screen.
    func test_ownRecognizer_onTheRootScreen_begins() {
        let root = BaseViewController()
        _ = UINavigationController(rootViewController: root)
        let tap = UITapGestureRecognizer()
        tap.delegate = root

        XCTAssertTrue(root.gestureRecognizerShouldBegin(tap))
    }

    func test_popGesture_beginsOnlyWithAScreenToGoBackTo() throws {
        let root = BaseViewController()
        let navigationController = UINavigationController(rootViewController: root)
        let popGesture = try XCTUnwrap(navigationController.interactivePopGestureRecognizer)

        XCTAssertFalse(root.gestureRecognizerShouldBegin(popGesture), "no swipe-back on the root screen")

        let pushed = BaseViewController()
        navigationController.pushViewController(pushed, animated: false)
        XCTAssertTrue(pushed.gestureRecognizerShouldBegin(popGesture), "swipe-back on a pushed screen")
    }

    /// A screen can block swipe-back by overriding the method; its other recognizers keep the base rule.
    func test_subclassOverride_blocksSwipeBack() throws {
        let navigationController = UINavigationController(rootViewController: BaseViewController())
        let blocking = SwipeBackBlockingViewController()
        navigationController.pushViewController(blocking, animated: false)
        let popGesture = try XCTUnwrap(navigationController.interactivePopGestureRecognizer)

        let asBase: BaseViewController = blocking
        XCTAssertFalse(asBase.gestureRecognizerShouldBegin(popGesture))
        XCTAssertTrue(asBase.gestureRecognizerShouldBegin(UITapGestureRecognizer()))
    }
}
