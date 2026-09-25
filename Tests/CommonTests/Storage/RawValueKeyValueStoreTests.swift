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

// MARK: - FileStorageTests

/// FileStorage's own behavior, exercised in a temporary directory: tests must never delete the
/// host's Documents directory.
final class FileStorageTests: XCTestCase {

    private var directory: URL!

    override func setUp() {
        super.setUp()
        directory = FileManager.default.temporaryDirectory.appendingPathComponent("FileStorageTests-\(UUID().uuidString)")
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: directory)
        directory = nil
        super.tearDown()
    }

    /// `Data.write(to:)` fails (silently, in the fire-and-forget API) when the parent directory
    /// doesn't exist, which is the state of a fresh app container.
    func test_add_createsTheDirectoryWhenMissing() {
        XCTAssertFalse(FileManager.default.fileExists(atPath: directory.path), "precondition: the directory is missing")
        let storage = FileStorage(directory: directory)

        storage.add(item: ("item", Item(value: "created")))

        let read: Item? = storage.get(using: "item")
        XCTAssertEqual(read, Item(value: "created"), "add must create the missing directory before writing")
    }

    /// An atomic write goes through a temporary file and a rename, so the stored file is a new one;
    /// an in-place write would truncate and reuse the old file, and an interrupted write would
    /// leave it partial.
    func test_add_overwrite_replacesTheFileAsAWhole() throws {
        let storage = FileStorage(directory: directory)
        storage.add(item: ("item", Item(value: "first")))
        let before = try fileNumber(of: "item")

        storage.add(item: ("item", Item(value: "second")))

        XCTAssertNotEqual(try fileNumber(of: "item"), before, "the overwrite must replace the file, not rewrite it in place")
        let read: Item? = storage.get(using: "item")
        XCTAssertEqual(read, Item(value: "second"))
    }

    func test_tryAdd_overwrite_replacesTheFileAsAWhole() throws {
        let storage = FileStorage(directory: directory)
        try storage.tryAdd(item: ("item", Item(value: "first"))).get()
        let before = try fileNumber(of: "item")

        try storage.tryAdd(item: ("item", Item(value: "second"))).get()

        XCTAssertNotEqual(try fileNumber(of: "item"), before, "the overwrite must replace the file, not rewrite it in place")
    }

    /// The shared storage keeps its location; this test writes its own key there and removes only it.
    func test_shared_storesInTheDocumentsDirectory() throws {
        let documents = try XCTUnwrap(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first)
        let key = "fs_default_location_item"
        defer { FileStorage.shared.remove(using: key) }

        FileStorage.shared.add(item: (key, Item(value: "here")))

        XCTAssertTrue(FileManager.default.fileExists(atPath: documents.appendingPathComponent(key).path))
    }

    private func fileNumber(of key: String) throws -> Int {
        let attributes = try FileManager.default.attributesOfItem(atPath: directory.appendingPathComponent(key).path)
        return try XCTUnwrap(attributes[.systemFileNumber] as? Int)
    }
}
