//
//  RawValueKeyValueStoreTests.swift
//

import XCTest
@testable import Common

// MARK: - Helpers

private struct Item: Storable, Equatable {
    let value: String
}

/// Conformer that declares a non-default backing store. Regression target:
/// `type` used to be a statically-dispatched private extension member, so this
/// declaration was silently ignored and everything landed in UserDefaults.
private struct FilesBackedStorage: SingleRawValueKeyValueObjectStorage {
    var type: KeyValueStore.StoreType { .notSecure(.files) }
    enum Keys: String { case item = "rvkvs_files_item" }
    func add(item: Item) { add(item: (.item, item)) }
    func get() -> Item? { get(using: .item) }
    func delete() { remove(using: .item) }
}

/// Conformer that declares nothing — must keep the historical UserDefaults default.
private struct DefaultBackedStorage: SingleRawValueKeyValueObjectStorage {
    enum Keys: String { case item = "rvkvs_default_item" }
    func add(item: Item) { add(item: (.item, item)) }
    func get() -> Item? { get(using: .item) }
    func delete() { remove(using: .item) }
}

// MARK: - RawValueKeyValueStoreTests

final class RawValueKeyValueStoreTests: XCTestCase {

    private let userDefaultsStore = KeyValueStore(type: .notSecure(.userDefaults))
    private let filesStore = KeyValueStore(type: .notSecure(.files))

    override func tearDown() {
        FilesBackedStorage().delete()
        DefaultBackedStorage().delete()
        super.tearDown()
    }

    /// A conformer's declared `type` must actually pick the backing store.
    func test_declaredStoreType_isHonored() {
        let stored = Item(value: "files")
        FilesBackedStorage().add(item: stored)

        let fromFiles: Item? = filesStore.get(using: "rvkvs_files_item")
        let fromDefaults: Item? = userDefaultsStore.get(using: "rvkvs_files_item")
        XCTAssertEqual(fromFiles, stored, "item must land in the declared .files store")
        XCTAssertNil(fromDefaults, "item must NOT leak into the UserDefaults default store")

        XCTAssertEqual(FilesBackedStorage().get(), stored)
    }

    /// Conformers that don't declare `type` keep the UserDefaults default.
    func test_defaultStoreType_isUserDefaults() {
        let stored = Item(value: "default")
        DefaultBackedStorage().add(item: stored)

        let fromDefaults: Item? = userDefaultsStore.get(using: "rvkvs_default_item")
        XCTAssertEqual(fromDefaults, stored)

        XCTAssertEqual(DefaultBackedStorage().get(), stored)
    }
}
