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

/// Conformer declaring `.secure` — the exact shape of the original bug report
/// (a "keychain" store silently writing to UserDefaults).
private struct SecureBackedStorage: SingleRawValueKeyValueObjectStorage {
    var type: KeyValueStore.StoreType { .secure }
    enum Keys: String { case item = "rvkvs_secure_item" }
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
        SecureBackedStorage().delete()
        super.tearDown()
    }

    /// `.secure` must route to the Keychain, not UserDefaults — the exact bug
    /// this suite exists for. Only the negative half is assertable: on unsigned
    /// simulator test hosts the keychain accepts writes but reads return nil,
    /// so a round-trip cannot be verified. The regression this guards (routing
    /// `.secure` to UserDefaults) IS caught: the buggy dispatch would make
    /// `fromDefaults` non-nil.
    func test_secureStoreType_doesNotWriteToUserDefaults() {
        SecureBackedStorage().add(item: Item(value: "secure"))

        let fromDefaults: Item? = userDefaultsStore.get(using: "rvkvs_secure_item")
        XCTAssertNil(fromDefaults, "a .secure conformer must NOT write to UserDefaults")
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

// MARK: - FileStorageDirectoryCreationTests

/// FileStorage must survive a missing Documents directory — `Data.write(to:)`
/// fails (silently, in the fire-and-forget API) when the parent directory
/// doesn't exist, which is the state of a fresh app container.
final class FileStorageDirectoryCreationTests: XCTestCase {

    func test_add_createsDocumentsDirectoryWhenMissing() throws {
        let documents = try XCTUnwrap(URL.documentsDirectory)
        // Only remove it when empty-or-absent-of-others: our own key is the sole
        // thing this suite writes there, and sibling tests recreate on demand.
        try? FileManager.default.removeItem(at: documents)
        defer { FileStorage.shared.remove(using: "fs_mkdir_item") }

        let stored = Item(value: "created")
        FileStorage.shared.add(item: ("fs_mkdir_item", stored))

        let read: Item? = FileStorage.shared.get(using: "fs_mkdir_item")
        XCTAssertEqual(read, stored, "add must create the missing Documents directory before writing")
    }
}
