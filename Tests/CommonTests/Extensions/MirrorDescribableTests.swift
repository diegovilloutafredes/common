//
//  MirrorDescribableTests.swift
//

import XCTest
@testable import Common

/// `MirrorDescribable` gives an adopting type a description that lists its stored properties.
final class MirrorDescribableTests: XCTestCase {

    private struct Item: MirrorDescribable {
        let name = "a"
        let count = 2
    }

    private struct Titled: MirrorDescribable {
        let name = "a"
        var description: String { "its own" }
    }

    /// Reflects as two children without labels, as a collection does.
    private struct Unlabeled: MirrorDescribable, CustomReflectable {
        var customMirror: Mirror { Mirror(self, unlabeledChildren: [1, 2]) }
    }

    func test_adoptingType_describesItsStoredPropertiesInDeclarationOrder() {
        XCTAssertEqual(Item().description, "name: a\ncount: 2")
    }

    func test_adoptingType_interpolatesAsItsDescription() {
        XCTAssertEqual("\(Item())", "name: a\ncount: 2")
    }

    func test_adoptingType_readThroughTheProtocol_describesItsStoredProperties() {
        let describable: any CustomStringConvertible = Item()

        XCTAssertEqual(describable.description, "name: a\ncount: 2")
    }

    func test_adoptingType_withItsOwnDescription_keepsIt() {
        XCTAssertEqual(Titled().description, "its own")
        XCTAssertEqual("\(Titled())", "its own")
    }

    func test_unlabeledChild_isListedAsNoLabel() {
        XCTAssertEqual(Unlabeled().description, "No label: 1\nNo label: 2")
    }

    @available(*, deprecated, message: "Pins the deprecated global description")
    func test_typeRelyingOnTheGlobalDefault_keepsTheSameText() {
        struct Legacy: CustomStringConvertible {
            let name = "a"
            let count = 2
        }

        XCTAssertEqual(Legacy().description, "name: a\ncount: 2")
        XCTAssertEqual("\(Legacy())", "name: a\ncount: 2")
    }
}
