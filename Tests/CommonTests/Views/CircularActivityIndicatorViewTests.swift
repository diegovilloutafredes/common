//
//  CircularActivityIndicatorViewTests.swift
//

import UIKit
import XCTest
@testable import Common

@MainActor
final class CircularActivityIndicatorViewTests: XCTestCase {

    private func makeView() -> CircularActivityIndicatorView {
        let view = CircularActivityIndicatorView(colors: [.red, .blue])
        view.frame = .init(x: 0, y: 0, width: 48, height: 48)
        view.layoutIfNeeded()
        return view
    }

    private func shapeLayer(of view: CircularActivityIndicatorView) throws -> CAShapeLayer {
        try XCTUnwrap((view.layer.sublayers ?? []).compactMap { $0 as? CAShapeLayer }.first)
    }

    /// Simulates Core Animation stripping the animations — what actually
    /// happens on window removal or app backgrounding in a real render tree
    /// (the headless harness does not strip them for us).
    private func stripAnimations(of view: CircularActivityIndicatorView) throws {
        try shapeLayer(of: view).removeAllAnimations()
        view.layer.removeAllAnimations()
    }

    private func assertAnimationsPresent(on view: CircularActivityIndicatorView, _ message: String,
                                         file: StaticString = #filePath, line: UInt = #line) throws {
        let shape = try shapeLayer(of: view)
        XCTAssertNotNil(shape.animation(forKey: "stroke"), message, file: file, line: line)
        XCTAssertNotNil(shape.animation(forKey: "colour"), message, file: file, line: line)
        XCTAssertNotNil(view.layer.animation(forKey: "rotation"), message, file: file, line: line)
    }

    // MARK: - Animation restoration (C1)

    func test_windowReentry_restoresStrippedAnimations() throws {
        let window = UIWindow(frame: .init(x: 0, y: 0, width: 100, height: 100))
        let view = makeView()
        view.isAnimating = true
        try stripAnimations(of: view)

        window.addSubview(view)

        try assertAnimationsPresent(on: view, "joining a window while isAnimating must re-add the CA-stripped animations")
        view.isAnimating = false
        view.removeFromSuperview()
    }

    func test_stoppedIndicator_gainsNoAnimationsOnWindowEntry() throws {
        let window = UIWindow(frame: .init(x: 0, y: 0, width: 100, height: 100))
        let view = makeView()
        view.isAnimating = false

        window.addSubview(view)

        let shape = try shapeLayer(of: view)
        XCTAssertNil(shape.animation(forKey: "stroke"), "a stopped indicator must stay stopped across window entry")
        XCTAssertNil(view.layer.animation(forKey: "rotation"))
        XCTAssertTrue(shape.isHidden)
        view.removeFromSuperview()
    }

    func test_foregroundNotification_restoresStrippedAnimations() throws {
        let window = UIWindow(frame: .init(x: 0, y: 0, width: 100, height: 100))
        let view = makeView()
        window.addSubview(view)
        view.isAnimating = true
        try stripAnimations(of: view)

        NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: nil)

        try assertAnimationsPresent(on: view, "returning to foreground must re-add the CA-stripped animations")
        view.isAnimating = false
        view.removeFromSuperview()
    }

    func test_foregroundNotification_doesNothingForStoppedIndicator() throws {
        let window = UIWindow(frame: .init(x: 0, y: 0, width: 100, height: 100))
        let view = makeView()
        window.addSubview(view)
        view.isAnimating = false

        NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: nil)

        let shape = try shapeLayer(of: view)
        XCTAssertNil(shape.animation(forKey: "stroke"))
        view.removeFromSuperview()
    }

    // MARK: - Stroke geometry (C2)

    func test_strokePathIsInsetByHalfLineWidth() throws {
        let lineWidth: CGFloat = 4
        let view = CircularActivityIndicatorView(colors: [.red], lineCap: .round, lineWidth: lineWidth)
        view.frame = .init(x: 0, y: 0, width: 48, height: 48)
        view.layoutIfNeeded()

        let shape = try shapeLayer(of: view)
        let expected = view.bounds.insetBy(dx: lineWidth / 2, dy: lineWidth / 2)
        XCTAssertEqual(try XCTUnwrap(shape.path).boundingBox, expected,
                       "the stroke is centered on the path — an un-inset path gets its outer half clipped by clipsToBounds")
    }

    // MARK: - Leak (foreground observer)

    func test_animatingIndicatorDeallocates() {
        weak var weakView: CircularActivityIndicatorView?
        autoreleasepool {
            let view = makeView()
            weakView = view
            view.isAnimating = true
            view.isAnimating = false
        }
        XCTAssertNil(weakView, "the indicator leaked — the foreground observer must capture self weakly and be removed on deinit")
    }
}
