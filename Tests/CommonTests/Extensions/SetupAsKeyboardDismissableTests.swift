//
//  SetupAsKeyboardDismissableTests.swift
//

import XCTest
@testable import Common

@MainActor
final class SetupAsKeyboardDismissableTests: XCTestCase {

    /// Regression: the tap handler used to capture the VC strongly, creating a
    /// VC → view → handler → VC cycle that leaked every VC that opted in.
    func test_setupAsKeyboardDismissable_doesNotRetainViewController() {
        weak var weakVC: UIViewController?
        autoreleasepool {
            let vc = UIViewController()
            vc.loadViewIfNeeded()
            vc.setupAsKeyboardDismissable()
            weakVC = vc
        }
        XCTAssertNil(weakVC, "setupAsKeyboardDismissable must not retain the view controller")
    }
}
