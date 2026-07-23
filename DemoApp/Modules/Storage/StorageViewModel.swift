//
//  StorageViewModel.swift
//  DemoApp
//

import Common
import Foundation

// MARK: - StorageItem
struct StorageItem: Storable {
    let value: String
    let timestamp: Date
}

// MARK: - StorageType
enum StorageType: String, CaseIterable {
    case userDefaults
    case file
    case keychain
    case inMemory

    var title: String {
        switch self {
        case .userDefaults: "UserDefaults"
        case .file: "FileStorage"
        case .keychain: "Keychain"
        case .inMemory: "InMemory"
        }
    }

    var description: String {
        switch self {
        case .userDefaults: "Best for app preferences and settings. Not encrypted."
        case .file: "Best for documents, cached data, and large payloads."
        case .keychain: "Best for passwords, tokens, and sensitive credentials. Encrypted."
        case .inMemory: "Best for tests and previews. Cleared when the app terminates."
        }
    }

    var exampleValue: String {
        switch self {
        case .userDefaults: "dark_mode: true"
        case .file: "profile_cache.json"
        case .keychain: "eyJhbGciOiJIUzI1NiJ9..."
        case .inMemory: "session_state: onboarding"
        }
    }

    var iconName: String {
        switch self {
        case .userDefaults: "gearshape.fill"
        case .file: "doc.fill"
        case .keychain: "lock.shield.fill"
        case .inMemory: "memorychip"
        }
    }

    var color: UIColor {
        switch self {
        case .userDefaults: .systemBlue
        case .file: .systemGreen
        case .keychain: .systemPurple
        case .inMemory: .systemOrange
        }
    }
}

// MARK: - StorageViewModelProtocol
protocol StorageViewModelProtocol: ViewModel {
    var title: String { get }
    func save(type: StorageType) -> StorageItem
    func read(type: StorageType) -> StorageItem?
    func delete(type: StorageType)
    func saveDirectSecret() -> String
    func readDirectSecret() -> String?
    func deleteDirectSecret()
}

// MARK: - DemoItemStorage
/// Typed enum-key storage over the backing store of the caller's choice —
/// the `SingleRawValueKeyValueObjectStorage` pattern from the framework guide.
private struct DemoItemStorage: SingleRawValueKeyValueObjectStorage {
    let type: KeyValueStore.StoreType

    enum Keys: String { case item = "demo_item" }

    func add(item: StorageItem) { add(item: (.item, item)) }
    func get() -> StorageItem? { get(using: .item) }
    func delete() { remove(using: .item) }
}

// MARK: - StorageViewModel
final class StorageViewModelImpl: StorageViewModelProtocol {
    let title = "Storage"

    // The in-memory backend is a live object, not a rebuildable value — hold one
    // instance so save/read hit the same store. This is InMemoryKeyValueStorage's
    // documented use: KeyValueStore(keyValueStorage:) with a test/preview backend.
    private let inMemoryStore = KeyValueStore(keyValueStorage: InMemoryKeyValueStorage())
    private let inMemoryKey = "demo_item"

    private func storage(for type: StorageType) -> DemoItemStorage? {
        switch type {
        case .userDefaults: .init(type: .notSecure(.userDefaults))
        case .file: .init(type: .notSecure(.files))
        case .keychain: .init(type: .secure)
        case .inMemory: nil // lives in inMemoryStore
        }
    }

    @discardableResult
    func save(type: StorageType) -> StorageItem {
        let item = StorageItem(value: type.exampleValue, timestamp: .now)
        if let storage = storage(for: type) {
            storage.add(item: item)
        } else {
            inMemoryStore.add(item: (inMemoryKey, item))
        }
        return item
    }

    func read(type: StorageType) -> StorageItem? {
        guard let storage = storage(for: type) else { return inMemoryStore.get(using: inMemoryKey) }
        return storage.get()
    }

    func delete(type: StorageType) {
        guard let storage = storage(for: type) else { return inMemoryStore.remove(using: inMemoryKey) }
        storage.delete()
    }
}

// MARK: - Direct KeychainWrapper (low-level API)
extension StorageViewModelImpl {
    private var directKey: String { "demo_direct_secret" }

    func saveDirectSecret() -> String {
        let secret = String.random(length: 12)
        KeychainWrapper.standard.set(secret, forKey: directKey)
        return secret
    }

    func readDirectSecret() -> String? {
        KeychainWrapper.standard.string(forKey: directKey)
    }

    func deleteDirectSecret() {
        KeychainWrapper.standard.removeObject(forKey: directKey)
    }
}
