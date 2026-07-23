//
//  SetAsRoundedViewTests.swift
//

import XCTest
import UIKit
@testable import Common

@MainActor
final class SetAsRoundedViewTests: XCTestCase {

    // MARK: - Explicit radius

    func test_explicitRadius_appliesSynchronously() {
        let view = UIView(frame: .init(x: 0, y: 0, width: 100, height: 40))
        view.setAsRoundedView(radius: 12)
        XCTAssertEqual(view.layer.cornerRadius, 12)
        XCTAssertTrue(view.clipsToBounds)
    }

    func test_explicitRadius_clearsPillBehavior() {
        let view = UIView(frame: .init(x: 0, y: 0, width: 100, height: 40))
        view.setAsRoundedView()                           // pill mode
        XCTAssertEqual(view.layer.cornerRadius, 20)
        view.setAsRoundedView(radius: 8)                  // switch to explicit
        XCTAssertEqual(view.layer.cornerRadius, 8)

        // Bounds change should *not* override the explicit radius — pill flag must be off.
        view.frame = .init(x: 0, y: 0, width: 100, height: 60)
        view.layoutSubviews()
        XCTAssertEqual(view.layer.cornerRadius, 8)
    }

    // MARK: - Pill mode

    func test_pillMode_appliesSynchronously_whenBoundsAlreadyValid() {
        let view = UIView(frame: .init(x: 0, y: 0, width: 100, height: 40))
        view.setAsRoundedView()
        XCTAssertEqual(view.layer.cornerRadius, 20)
        XCTAssertTrue(view.clipsToBounds)
    }

    func test_pillMode_constructionTimeChain_picksUpFirstLayoutPass() {
        let view = UIView()
        view.setAsRoundedView()
        XCTAssertEqual(view.layer.cornerRadius, 0)        // bounds zero at call time → no sync apply

        view.frame = .init(x: 0, y: 0, width: 100, height: 40)
        view.layoutSubviews()                             // first layout pass → persistent flag fires
        XCTAssertEqual(view.layer.cornerRadius, 20)
    }

    func test_pillMode_tracksHeightAcrossResize() {
        let view = UIView(frame: .init(x: 0, y: 0, width: 100, height: 40))
        view.setAsRoundedView()
        XCTAssertEqual(view.layer.cornerRadius, 20)

        view.frame = .init(x: 0, y: 0, width: 100, height: 60)
        view.layoutSubviews()
        XCTAssertEqual(view.layer.cornerRadius, 30)

        view.frame = .init(x: 0, y: 0, width: 100, height: 24)
        view.layoutSubviews()
        XCTAssertEqual(view.layer.cornerRadius, 12)
    }

    func test_pillMode_calledInsideLayoutSubviews_correctOnFirstPaint() {
        final class FooView: UIView {
            override func layoutSubviews() {
                super.layoutSubviews()
                setAsRoundedView()
            }
        }
        let view = FooView(frame: .init(x: 0, y: 0, width: 100, height: 40))
        view.layoutSubviews()
        XCTAssertEqual(view.layer.cornerRadius, 20,
                       "Pill mode must apply synchronously when called inside layoutSubviews.")
    }

    func test_pillMode_calledInsideAnotherOnLayoutSubviewsHandler_correctOnFirstPaint() {
        let view = UIView(frame: .init(x: 0, y: 0, width: 100, height: 40))
        view.onLayoutSubviews { $0.setAsRoundedView() }
        view.layoutSubviews()
        XCTAssertEqual(view.layer.cornerRadius, 20,
                       "Pill mode must apply synchronously when called inside another onLayoutSubviews handler.")
    }

    func test_pillMode_respectsMaskedCorners() {
        let topCorners: CACornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        let view = UIView(frame: .init(x: 0, y: 0, width: 100, height: 40))
        view.setAsRoundedView(using: topCorners)
        XCTAssertEqual(view.layer.maskedCorners, topCorners)
        XCTAssertEqual(view.layer.cornerRadius, 20)

        // Pill mode re-applies on every layout pass from stored state — a
        // re-application that defaults back to all corners silently un-rounds
        // a top-corners pill after the first resize/rotation.
        view.frame = .init(x: 0, y: 0, width: 100, height: 60)
        view.layoutSubviews()
        XCTAssertEqual(view.layer.maskedCorners, topCorners, "re-application must keep the stored corners")
        XCTAssertEqual(view.layer.cornerRadius, 30)
    }

    // MARK: - onLayoutSubviews queue (multi-handler)

    func test_multipleOnLayoutSubviewsHandlers_allFireInOrder() {
        let view = UIView(frame: .init(x: 0, y: 0, width: 100, height: 40))
        var fired: [Int] = []
        view.onLayoutSubviews { _ in fired.append(1) }
        view.onLayoutSubviews { _ in fired.append(2) }
        view.onLayoutSubviews { _ in fired.append(3) }
        view.layoutSubviews()
        XCTAssertEqual(fired, [1, 2, 3])
    }

    func test_onLayoutSubviewsHandlers_fireOnceThenAreRemoved() {
        let view = UIView(frame: .init(x: 0, y: 0, width: 100, height: 40))
        var calls = 0
        view.onLayoutSubviews { _ in calls += 1 }
        view.layoutSubviews()
        view.layoutSubviews()
        XCTAssertEqual(calls, 1)
    }

    func test_handlerQueueingFromInsideHandler_firesOnNextPass() {
        let view = UIView(frame: .init(x: 0, y: 0, width: 100, height: 40))
        var outerCount = 0
        var innerCount = 0
        view.onLayoutSubviews { v in
            outerCount += 1
            v.onLayoutSubviews { _ in innerCount += 1 }
        }
        view.layoutSubviews()
        XCTAssertEqual(outerCount, 1)
        XCTAssertEqual(innerCount, 0, "A handler queued from inside another handler must wait for the next pass.")
        view.layoutSubviews()
        XCTAssertEqual(innerCount, 1)
    }

    // MARK: - Interaction between pill and handler queue

    func test_pillSurvives_unrelatedOnLayoutSubviewsHandler() {
        let view = UIView(frame: .init(x: 0, y: 0, width: 100, height: 40))
        var handlerFired = false
        view.setAsRoundedView()
        view.onLayoutSubviews { _ in handlerFired = true }
        view.layoutSubviews()
        XCTAssertEqual(view.layer.cornerRadius, 20, "Pill flag must not be overwritten by an unrelated handler.")
        XCTAssertTrue(handlerFired)

        // After the handler is drained, pill must keep applying.
        view.frame = .init(x: 0, y: 0, width: 100, height: 60)
        view.layoutSubviews()
        XCTAssertEqual(view.layer.cornerRadius, 30)
    }
}
