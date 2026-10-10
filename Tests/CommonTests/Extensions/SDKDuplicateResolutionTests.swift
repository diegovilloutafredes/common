//
//  SDKDuplicateResolutionTests.swift
//

// Compiling this file is the assertion. Common declares the members read below with the same type and value as
// Foundation and UIKit do, and a file that imports those modules as well as Common must resolve each read to one
// declaration. Keep the four imports explicit: without Foundation and UIKit the file proves nothing.
import Foundation
import UIKit
import XCTest
import Common

final class SDKDuplicateResolutionTests: XCTestCase {

    func test_bundleIdentifier_isTheBundlesIdentifier() {
        XCTAssertEqual(Bundle.main.bundleIdentifier, Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String)
    }

    func test_directionalEdgeInsetsZero_isAllZeros() {
        let zeros = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        let insets: NSDirectionalEdgeInsets = .zero

        XCTAssertEqual(NSDirectionalEdgeInsets.zero, zeros)
        XCTAssertEqual(insets, zeros)
        XCTAssertEqual(passedThrough(.zero), zeros)
    }

    private func passedThrough(_ insets: NSDirectionalEdgeInsets) -> NSDirectionalEdgeInsets { insets }
}
