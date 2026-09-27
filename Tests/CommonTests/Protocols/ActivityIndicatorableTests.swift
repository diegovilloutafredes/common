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
        // Presence is not visibility: hidesWhenStopped defaults to true, so an
        // installed-but-stopped spinner renders as nothing.
        XCTAssertEqual((textField.rightView as? UIActivityIndicatorView)?.isAnimating, true,
                       "the installed spinner must be animating — a stopped one is invisible")

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
        let spinner = view.subviews.compactMap { $0 as? UIActivityIndicatorView }.first
        XCTAssertNotNil(spinner)
        // Presence is not visibility: hidesWhenStopped defaults to true, so an
        // installed-but-stopped spinner renders as nothing.
        XCTAssertEqual(spinner?.isAnimating, true,
                       "the installed spinner must be animating — a stopped one is invisible")

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

    /// The defect: hiding the subviews for the spinner zeroed their alpha, and stopping set it to 1.
    func test_view_roundTrip_keepsSubviewAlpha() {
        let view = IndicatorView()
        let translucentSubview = UIView()
        translucentSubview.alpha = 0.5
        view.addSubview(translucentSubview)

        view.startActivityIndicator()
        view.stopActivityIndicator()

        XCTAssertFalse(translucentSubview.isHidden)
        XCTAssertEqual(translucentSubview.alpha, 0.5)
    }

    // MARK: - Default color

    private let light = UITraitCollection(userInterfaceStyle: .light)
    private let dark = UITraitCollection(userInterfaceStyle: .dark)

    private func spinnerColor(in view: UIView) throws -> UIColor {
        let spinner = try XCTUnwrap(view.subviews.compactMap { $0 as? UIActivityIndicatorView }.first)
        return try XCTUnwrap(spinner.color)
    }

    /// Compares resolved colors by components, so the same color in two color spaces still matches.
    private func assertColor(_ color: UIColor, equals expected: UIColor, in traits: UITraitCollection, line: UInt = #line) {
        func rgba(_ color: UIColor) -> [CGFloat] {
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            color.resolvedColor(with: traits).getRed(&r, green: &g, blue: &b, alpha: &a)
            return [r, g, b, a]
        }
        zip(rgba(color), rgba(expected)).forEach { XCTAssertEqual($0, $1, accuracy: 0.001, line: line) }
    }

    /// The defect: the inverted background kept the background's alpha, so a clear background gave an invisible spinner.
    func test_view_defaultColor_onClearBackground_isOpaqueLabel() throws {
        let view = IndicatorView()
        view.backgroundColor = .clear

        view.startActivityIndicator()

        let color = try spinnerColor(in: view)
        assertColor(color, equals: .label, in: light)
        assertColor(color, equals: .label, in: dark)
    }

    func test_view_defaultColor_onOpaqueWhite_isOpaqueBlack() throws {
        let view = IndicatorView()
        view.backgroundColor = .white

        view.startActivityIndicator()

        assertColor(try spinnerColor(in: view), equals: .black, in: light)
    }

    func test_view_defaultColor_onMostlyTransparentBackground_isOpaqueLabel() throws {
        let view = IndicatorView()
        view.backgroundColor = .black.withAlphaComponent(0.3)

        view.startActivityIndicator()

        assertColor(try spinnerColor(in: view), equals: .label, in: light)
    }

    /// The defect: with no background the fallback was black, invisible in dark mode.
    func test_view_defaultColor_withoutBackground_followsTheAppearance() throws {
        let view = IndicatorView()

        view.startActivityIndicator()

        assertColor(try spinnerColor(in: view), equals: .label, in: dark)
    }

    func test_textField_defaultColor_usesTextColor() throws {
        let textField = IndicatorTextField()
        textField.textColor = .red

        textField.startActivityIndicator()

        let spinner = try XCTUnwrap(textField.rightView as? UIActivityIndicatorView)
        XCTAssertEqual(spinner.color, .red)
    }
}
