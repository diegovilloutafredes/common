//
//  SetupAsKeyboardDismissableTests.swift
//

import XCTest
@testable import Common

@MainActor
final class SetupAsKeyboardDismissableTests: XCTestCase {

    /// The feature itself: tapping the view must resign the first responder.
    /// (Previously only the leak was tested — deleting the entire wiring kept
    /// the suite green while shipping a keyboard that never dismissed.)
    func test_tapOnView_resignsFirstResponder() throws {
        let window = UIWindow(frame: .init(x: 0, y: 0, width: 320, height: 640))
        let vc = UIViewController()
        window.rootViewController = vc
        window.makeKeyAndVisible()
        defer { window.isHidden = true }

        let textField = UITextField()
        vc.view.addSubview(textField)
        vc.setupAsKeyboardDismissable()
        textField.becomeFirstResponder()
        XCTAssertTrue(textField.isFirstResponder, "precondition: the text field must hold first responder before the tap")

        // Synthesized touches don't exist in the unit harness — drive the
        // recognizer's registered action (the view's onTap trampoline) directly.
        let tap = try XCTUnwrap(
            vc.view.gestureRecognizers?.compactMap { $0 as? UITapGestureRecognizer }.first,
            "setupAsKeyboardDismissable must install a tap recognizer on the view"
        )
        vc.view.perform(NSSelectorFromString("onTappedWithSender:"), with: tap)

        XCTAssertFalse(textField.isFirstResponder, "tapping the view must dismiss the keyboard (resign first responder)")
    }

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
