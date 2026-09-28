//
//  UIButtonConfigurationTests.swift
//

import UIKit
import XCTest
@testable import Common

@MainActor
final class UIButtonConfigurationTests: XCTestCase {

    func test_title_setsTheTitleInAChain() {
        let configuration = UIButton.Configuration.filled().title("Pay").baseBackgroundColor(.black)

        XCTAssertEqual(configuration.title, "Pay")
        XCTAssertEqual(configuration.baseBackgroundColor, .black)
    }
}
