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
        // recognizer's registered action directly.
        let tap = try XCTUnwrap(
            vc.view.gestureRecognizers?.compactMap { $0 as? KeyboardDismissTapGestureRecognizer }.first,
            "setupAsKeyboardDismissable must install its tap recognizer on the view"
        )
        tap.recognized()

        XCTAssertFalse(textField.isFirstResponder, "tapping the view must dismiss the keyboard (resign first responder)")
    }

    private func tapRecognizers(on view: UIView) -> [UITapGestureRecognizer] {
        view.gestureRecognizers?.compactMap { $0 as? UITapGestureRecognizer } ?? []
    }

    /// The defect: the recognizer cancelled the touches it saw, swallowing cell selection, picker rows and other taps
    /// under it while the keyboard was up.
    func test_dismissalRecognizer_letsTouchesThrough() {
        let vc = UIViewController()
        vc.loadViewIfNeeded()
        vc.setupAsKeyboardDismissable()

        let taps = tapRecognizers(on: vc.view)
        XCTAssertFalse(taps.isEmpty, "setupAsKeyboardDismissable must install a tap recognizer")
        XCTAssertTrue(taps.allSatisfy { !$0.cancelsTouchesInView }, "keyboard dismissal must not cancel the tap's touches")
    }

    /// The defect: dismissal lived in the view's single onTap slot, so a later onTap silently replaced it.
    func test_onTapAfterSetup_keepsDismissal() {
        let vc = UIViewController()
        vc.loadViewIfNeeded()
        vc.setupAsKeyboardDismissable()
        vc.view.onTap { _ in }

        XCTAssertEqual(tapRecognizers(on: vc.view).count, 2, "onTap must add its own recognizer next to the dismissal one")
    }

    func test_setupTwice_installsOneRecognizer() {
        let vc = UIViewController()
        vc.loadViewIfNeeded()
        vc.setupAsKeyboardDismissable()
        vc.setupAsKeyboardDismissable()

        XCTAssertEqual(tapRecognizers(on: vc.view).count, 1)
    }

    /// Two tap recognizers on one view don't both recognize by default; the dismissal one must allow it, so a tap
    /// both dismisses the keyboard and runs the view's onTap handler.
    func test_dismissalRecognizer_recognizesAlongsideOtherRecognizers() throws {
        let vc = UIViewController()
        vc.loadViewIfNeeded()
        vc.setupAsKeyboardDismissable()
        vc.view.onTap { _ in }

        let dismissal = try XCTUnwrap(tapRecognizers(on: vc.view).first { !$0.cancelsTouchesInView })
        let other = try XCTUnwrap(tapRecognizers(on: vc.view).first { $0 !== dismissal })
        XCTAssertEqual(dismissal.delegate?.gestureRecognizer?(dismissal, shouldRecognizeSimultaneouslyWith: other), true)
    }

    /// Controls and text inputs keep their taps, as UIKit gives them over any parent tap recognizer: a tap on another
    /// field must move the focus, not end editing (a DemoApp UI test caught the version that ended it).
    func test_tapsOnControlsAndTextInputs_doNotEndEditing() {
        let root = UIView()
        let field = UITextField(), button = UIButton(), textView = UITextView(), label = UILabel(), buttonLabel = UILabel()
        [field, button, textView, label].forEach(root.addSubview)
        button.addSubview(buttonLabel)

        XCTAssertFalse(KeyboardDismissTapGestureRecognizer.endsEditing(forTapOn: field, in: root))
        XCTAssertFalse(KeyboardDismissTapGestureRecognizer.endsEditing(forTapOn: button, in: root))
        XCTAssertFalse(KeyboardDismissTapGestureRecognizer.endsEditing(forTapOn: buttonLabel, in: root), "inside a control")
        XCTAssertFalse(KeyboardDismissTapGestureRecognizer.endsEditing(forTapOn: textView, in: root))
        XCTAssertTrue(KeyboardDismissTapGestureRecognizer.endsEditing(forTapOn: label, in: root))
        XCTAssertTrue(KeyboardDismissTapGestureRecognizer.endsEditing(forTapOn: root, in: root))
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
