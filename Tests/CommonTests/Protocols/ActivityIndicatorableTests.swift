//
//  ActivityIndicatorableTests.swift
//

import UIKit
import XCTest
@testable import Common

@MainActor
final class ActivityIndicatorableTests: XCTestCase {

    // UIView (and therefore UITextField) already conforms to ActivityIndicatorable in Common.
    private typealias IndicatorTextField = UITextField
    private typealias IndicatorView = UIView

    // MARK: - UITextField

    func test_textField_roundTrip_restoresToggleVisibilityButton() {
        let textField = IndicatorTextField().addToggleVisibilityButton()
        let originalRightView = textField.rightView
        XCTAssertNotNil(originalRightView)

        textField.startActivityIndicator()
        XCTAssertTrue(textField.rightView is UIActivityIndicatorView)

        textField.stopActivityIndicator()
        XCTAssertTrue(textField.rightView === originalRightView)
    }

    func test_textField_stopWithoutStart_leavesRightViewUntouched() {
        let textField = IndicatorTextField()
        let customRightView = UIButton()
        textField.rightView = customRightView

        textField.stopActivityIndicator()
        XCTAssertTrue(textField.rightView === customRightView)
    }

    func test_textField_doubleStart_preservesOriginalStash() {
        let textField = IndicatorTextField()
        let customRightView = UIButton()
        textField.rightView = customRightView

        textField.startActivityIndicator()
        textField.startActivityIndicator()
        textField.stopActivityIndicator()

        XCTAssertTrue(textField.rightView === customRightView)
    }

    func test_textField_restoresRightViewMode() {
        let textField = IndicatorTextField()
        textField.rightView = UIButton()
        textField.rightViewMode = .whileEditing

        textField.startActivityIndicator()
        textField.stopActivityIndicator()

        XCTAssertEqual(textField.rightViewMode, .whileEditing)
    }

    // MARK: - UIView

    func test_view_roundTrip_keepsPreHiddenSubviewHidden() {
        let view = IndicatorView()
        let visibleSubview = UIView()
        let hiddenSubview = UIView()
        hiddenSubview.isHidden = true
        view.addSubview(visibleSubview)
        view.addSubview(hiddenSubview)

        view.startActivityIndicator()
        view.stopActivityIndicator()

        XCTAssertFalse(visibleSubview.isHidden)
        XCTAssertTrue(hiddenSubview.isHidden)
    }

    func test_view_stop_removesSpinner() {
        let view = IndicatorView()
        view.addSubview(UIView())

        view.startActivityIndicator()
        XCTAssertTrue(view.subviews.contains { $0 is UIActivityIndicatorView })

        view.stopActivityIndicator()
        XCTAssertFalse(view.subviews.contains { $0 is UIActivityIndicatorView })
    }

    func test_view_doubleStart_preservesOriginalHiddenStateRecord() {
        let view = IndicatorView()
        let visibleSubview = UIView()
        view.addSubview(visibleSubview)

        view.startActivityIndicator()
        view.startActivityIndicator()
        view.stopActivityIndicator()

        XCTAssertFalse(visibleSubview.isHidden)
    }

    func test_view_stopWithoutStart_doesNotDisturbSubviewState() {
        let view = IndicatorView()
        let hiddenSubview = UIView()
        hiddenSubview.isHidden = true
        view.addSubview(hiddenSubview)

        view.stopActivityIndicator()

        XCTAssertTrue(hiddenSubview.isHidden)
    }
}
