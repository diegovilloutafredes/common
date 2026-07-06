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

    // int/bool round-trips were dropped: every Storable type traverses the same
    // asData()/decoded() path (no per-type branching), so the string + struct
    // pair covers the encoding surface.

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

    // MARK: - Result-based API (error propagation)

    func test_tryAdd_writesAndRoundTrips() {
        let item = Item(id: 1, label: "a")

        let result = storage.tryAdd(item: ("key", item))

        guard case .success = result else { return XCTFail("Expected .success, got \(result)") }
        let read: Item? = storage.get(using: "key")
        XCTAssertEqual(read, item, "tryAdd must actually write the value")
    }

    func test_tryGet_typeMismatch_returnsDecodingFailed() {
        storage.add(item: ("key", "just a string"))

        let result: Result<Item?, StorageError> = storage.tryGet(using: "key")

        // Present-but-undecodable data must surface as an error, not be silently
        // converted into "key not found".
        guard case .failure(.decodingFailed) = result else {
            return XCTFail("Expected .failure(.decodingFailed), got \(result)")
        }
    }

    func test_tryRemove_clearsKeyAndSucceeds() {
        storage.add(item: ("key", "value"))

        let result = storage.tryRemove(using: "key")

        guard case .success = result else { return XCTFail("Expected .success, got \(result)") }
        let read: String? = storage.get(using: "key")
        XCTAssertNil(read)
    }

    // MARK: - KeyValueStore facade delegation

    func test_keyValueStoreFacade_delegatesToInjectedBackend() {
        let backend = InMemoryKeyValueStorage()
        let store = KeyValueStore(keyValueStorage: backend)
        let item = Item(id: 3, label: "delegated")

        store.add(item: ("key", item))

        let viaFacade: Item? = store.get(using: "key")
        let viaBackend: Item? = backend.get(using: "key")
        XCTAssertEqual(viaFacade, item)
        XCTAssertEqual(viaBackend, item, "the facade must delegate to the injected backend, not its own storage")

        store.remove(using: "key")
        let afterRemove: Item? = backend.get(using: "key")
        XCTAssertNil(afterRemove)
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
