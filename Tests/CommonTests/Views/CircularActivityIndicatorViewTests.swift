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

    // MARK: - Dynamic stroke colors (C3)

    private static let dynamicColor = UIColor { traits in
        traits.userInterfaceStyle == .dark ? .white : .black
    }

    /// Hosts a dynamic-color indicator in a key window so window-level
    /// appearance overrides propagate trait changes to it.
    private func makeHostedDynamicColorView() -> (UIWindow, CircularActivityIndicatorView) {
        let window = UIWindow(frame: .init(x: 0, y: 0, width: 100, height: 100))
        window.makeKeyAndVisible()
        let view = CircularActivityIndicatorView(colors: [Self.dynamicColor])
        view.frame = .init(x: 0, y: 0, width: 48, height: 48)
        window.addSubview(view)
        view.layoutIfNeeded()
        return (window, view)
    }

    private func firstKeyframeColor(of view: CircularActivityIndicatorView) throws -> UIColor {
        let shape = try shapeLayer(of: view)
        let colour = try XCTUnwrap(shape.animation(forKey: "colour") as? CAKeyframeAnimation)
        let first = try XCTUnwrap((colour.values as? [Any])?.first)
        return UIColor(cgColor: first as! CGColor)
    }

    private func assertColorEqual(_ color: UIColor, _ expected: UIColor,
                                  _ message: String, file: StaticString = #filePath, line: UInt = #line) {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0
        color.getRed(&r1, green: &g1, blue: &b1, alpha: nil)
        expected.getRed(&r2, green: &g2, blue: &b2, alpha: nil)
        XCTAssertEqual(r1, r2, accuracy: 0.01, message, file: file, line: line)
        XCTAssertEqual(g1, g2, accuracy: 0.01, message, file: file, line: line)
        XCTAssertEqual(b1, b2, accuracy: 0.01, message, file: file, line: line)
    }

    func test_strokeColors_resolveAgainstCurrentTraitsAtAnimationStart() throws {
        let (window, view) = makeHostedDynamicColorView()
        defer { window.isHidden = true }
        window.overrideUserInterfaceStyle = .dark
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))

        view.isAnimating = true

        assertColorEqual(try firstKeyframeColor(of: view), .white,
                         "keyframe colors must resolve against the view's traits, not UIColor's ambient default")
        let shape = try shapeLayer(of: view)
        assertColorEqual(UIColor(cgColor: try XCTUnwrap(shape.strokeColor)), .white,
                         "the base stroke color must resolve against the view's traits too")
        view.isAnimating = false
    }

    func test_darkModeFlip_reResolvesStrokeColorsWhileAnimating() throws {
        let (window, view) = makeHostedDynamicColorView()
        defer { window.isHidden = true }
        view.isAnimating = true
        assertColorEqual(try firstKeyframeColor(of: view), .black, "precondition: light appearance resolves the light variant")

        window.overrideUserInterfaceStyle = .dark
        // Trait propagation from the window runs on the UIKit update cycle —
        // give it one pass. (No layout is run on the view itself.)
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))
        XCTAssertEqual(view.traitCollection.userInterfaceStyle, .dark,
                       "precondition: the trait must reach the view before the hook can be judged")

        assertColorEqual(try firstKeyframeColor(of: view), .white,
                         "a dark/light flip while animating must re-add the stroke animations with re-resolved colors")
        view.isAnimating = false
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
