//
//  ProgressAnimationViewTests.swift
//

import UIKit
import XCTest
@testable import Common

@MainActor
final class ProgressAnimationViewTests: XCTestCase {

    private func makeView() -> ProgressAnimationView {
        let view = ProgressAnimationView(frame: .init(x: 0, y: 0, width: 100, height: 20))
        view.layoutIfNeeded()
        return view
    }

    private func gradientSublayers(of view: ProgressAnimationView) -> [CAGradientLayer] {
        (view.layer.sublayers ?? []).compactMap { $0 as? CAGradientLayer }
    }

    /// The animation actually added to the layer — `add(_:forKey:)` copies the
    /// animation, so delegate callbacks carry the copy, never the original.
    private func addedAnimation(of view: ProgressAnimationView, index: Int = 0) throws -> CAAnimation {
        try XCTUnwrap(gradientSublayers(of: view)[safe: index]?.animation(forKey: "loc"))
    }

    // MARK: - Completion delivery (exactly once, regardless of how it ends)

    func test_completionFires_whenAnimationIsStrippedUnfinished() throws {
        let view = makeView()
        var completions = 0
        view.animate(progressColor: UIColor.red.cgColor, backgroundColor: UIColor.gray.cgColor, duration: 10) { completions += 1 }
        let animation = try addedAnimation(of: view)

        // CA reports finished == false when the animation is stripped
        // (backgrounding, window removal) — the completion must still fire.
        view.animationDidStop(animation, finished: false)

        XCTAssertEqual(completions, 1, "a stripped animation must not swallow the completion — the caller's flow stalls")
    }

    func test_completionFires_exactlyOnce_onRepeatedDelivery() throws {
        let view = makeView()
        var completions = 0
        view.animate(progressColor: UIColor.red.cgColor, backgroundColor: UIColor.gray.cgColor, duration: 10) { completions += 1 }
        let animation = try addedAnimation(of: view)

        view.animationDidStop(animation, finished: true)
        view.animationDidStop(animation, finished: false)

        XCTAssertEqual(completions, 1, "the completion must be delivered exactly once")
    }

    func test_naturalFinish_firesCompletionOnce() throws {
        let view = makeView()
        var completions = 0
        view.animate(progressColor: UIColor.red.cgColor, backgroundColor: UIColor.gray.cgColor, duration: 10) { completions += 1 }
        let animation = try addedAnimation(of: view)

        view.animationDidStop(animation, finished: true)

        XCTAssertEqual(completions, 1)
    }

    // MARK: - Overlapping calls (no cross-wiring)

    func test_overlappingAnimateCalls_dontCrossWireCompletions() throws {
        let view = makeView()
        var first = 0
        var second = 0

        view.animate(progressColor: UIColor.red.cgColor, backgroundColor: UIColor.gray.cgColor, duration: 10) { first += 1 }
        let firstAnimation = try addedAnimation(of: view)

        view.animate(progressColor: UIColor.blue.cgColor, backgroundColor: UIColor.gray.cgColor, duration: 10) { second += 1 }
        XCTAssertEqual(first, 1, "a superseded call's completion fires at supersede time — never silently dropped")
        XCTAssertEqual(second, 0)

        // A stale callback from the superseded animation must not touch the new call.
        view.animationDidStop(firstAnimation, finished: false)
        XCTAssertEqual(first, 1)
        XCTAssertEqual(second, 0, "a stale animation callback must not fire the active call's completion")

        let secondAnimation = try addedAnimation(of: view)
        view.animationDidStop(secondAnimation, finished: true)
        XCTAssertEqual(second, 1)
    }

    // MARK: - Layer lifecycle

    func test_repeatedAnimateCalls_leaveAtMostOneGradientSublayer() {
        let view = makeView()
        for _ in 0..<3 {
            view.animate(progressColor: UIColor.red.cgColor, backgroundColor: UIColor.gray.cgColor, duration: 10, completion: nil)
        }
        XCTAssertEqual(gradientSublayers(of: view).count, 1, "each animate call must clean up the previous gradient layer")
    }

    func test_gradientLayerFollowsLayout() {
        let view = ProgressAnimationView(frame: .zero)
        view.animate(progressColor: UIColor.red.cgColor, backgroundColor: UIColor.gray.cgColor, duration: 10, completion: nil)

        view.frame = .init(x: 0, y: 0, width: 100, height: 20)
        view.layoutIfNeeded()

        XCTAssertEqual(gradientSublayers(of: view).first?.frame, view.bounds,
                       "an animate call made before layout must not leave the gradient at a zero/stale frame")
    }

    // MARK: - Leak (strong CAAnimation.delegate)

    func test_animatedViewDeallocates_whenNeverInWindow() {
        weak var weakView: ProgressAnimationView?
        autoreleasepool {
            let view = makeView()
            weakView = view
            view.animate(progressColor: UIColor.red.cgColor, backgroundColor: UIColor.gray.cgColor, duration: 10, completion: nil)
            // leaves scope off-window: the animation never runs, so it is never
            // removed — a strong delegate would keep the view alive forever
        }
        XCTAssertNil(weakView, "ProgressAnimationView leaked — CAAnimation.delegate is strong; use a weak proxy")
    }
}
