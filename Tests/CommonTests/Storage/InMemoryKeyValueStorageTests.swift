//
//  InMemoryKeyValueStorageTests.swift
//

import XCTest
@testable import Common

// MARK: - Helpers

private struct Item: Storable, Equatable {
    let id: Int
    let label: String
}

// MARK: - InMemoryKeyValueStorageTests

final class InMemoryKeyValueStorageTests: XCTestCase {

    private var storage: InMemoryKeyValueStorage!

    override func setUp() {
        super.setUp()
        storage = InMemoryKeyValueStorage()
    }

    override func tearDown() {
        storage.reset()
        storage = nil
        super.tearDown()
    }

    // MARK: - Round-trip

    func test_roundTrip_string() {
        storage.add(item: ("key", "hello"))
        let result: String? = storage.get(using: "key")
        XCTAssertEqual(result, "hello")
    }

    func test_roundTrip_int() {
        storage.add(item: ("count", 42))
        let result: Int? = storage.get(using: "count")
        XCTAssertEqual(result, 42)
    }

    func test_roundTrip_bool() {
        storage.add(item: ("flag", true))
        let result: Bool? = storage.get(using: "flag")
        XCTAssertEqual(result, true)
    }

    func test_roundTrip_codableStruct() {
        let item = Item(id: 7, label: "widget")
        storage.add(item: ("item", item))
        let result: Item? = storage.get(using: "item")
        XCTAssertEqual(result, item)
    }

    // MARK: - Remove

    func test_remove_clearsKey() {
        storage.add(item: ("key", "value"))
        storage.remove(using: "key")
        let result: String? = storage.get(using: "key")
        XCTAssertNil(result)
    }

    // MARK: - Reset

    func test_reset_clearsAllKeys() {
        storage.add(item: ("a", "one"))
        storage.add(item: ("b", "two"))
        storage.reset()
        let a: String? = storage.get(using: "a")
        let b: String? = storage.get(using: "b")
        XCTAssertNil(a)
        XCTAssertNil(b)
    }

    // MARK: - tryGet missing key

    func test_tryGet_missingKey_returnsSuccessNil() {
        let result: Result<String?, StorageError> = storage.tryGet(using: "missing")
        switch result {
        case .success(let value): XCTAssertNil(value)
        case .failure: XCTFail("Expected .success(nil) for missing key")
        }
    }

    // MARK: - StorageError localizedDescription

    func test_storageError_keychainNotFound_description() {
        let error = StorageError.keychainError(errSecItemNotFound)
        XCTAssertEqual(error.localizedDescription, "Keychain item not found.")
    }

    func test_storageError_keychainAuthFailed_description() {
        let error = StorageError.keychainError(errSecAuthFailed)
        XCTAssertEqual(error.localizedDescription, "Keychain authentication failed.")
    }
}
