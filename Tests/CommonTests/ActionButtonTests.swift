//
//  ActionButtonTests.swift
//

import XCTest
import UIKit
@testable import Common

@MainActor
final class ActionButtonTests: XCTestCase {

    func test_layoutSubviews_setsPillCornerRadius() {
        let button = ActionButton("Test")
        button.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        button.layoutSubviews()
        XCTAssertEqual(button.layer.cornerRadius, 25, accuracy: 0.001)
    }

    func test_layoutSubviews_updatesCornerRadiusOnResize() {
        let button = ActionButton("Test")
        button.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
        button.layoutSubviews()
        XCTAssertEqual(button.layer.cornerRadius, 20, accuracy: 0.001)

        button.frame = CGRect(x: 0, y: 0, width: 327, height: 60)
        button.layoutSubviews()
        XCTAssertEqual(button.layer.cornerRadius, 30, accuracy: 0.001)
    }

    func test_clipsToBounds_isTrue() {
        let button = ActionButton("Test")
        XCTAssertTrue(button.clipsToBounds)
    }
}
