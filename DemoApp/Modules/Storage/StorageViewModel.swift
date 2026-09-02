//
//  StorageViewModel.swift
//  DemoApp
//

import Common
import Foundation
import Observation

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
@MainActor
protocol StorageViewModelProtocol: ViewModel {
    var title: String { get }
    /// What each backend currently holds (absent = empty). Refreshed by every operation.
    var stored: [StorageType: StorageItem] { get }
    var directSecret: String? { get }
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
@Observable
@MainActor
final class StorageViewModelImpl: StorageViewModelProtocol {
    let title = "Storage"
    private(set) var stored: [StorageType: StorageItem] = [:]
    private(set) var directSecret: String?

    // The in-memory backend is a live object, not a rebuildable value — hold one
    // instance so save/read hit the same store. This is InMemoryKeyValueStorage's
    // documented use: KeyValueStore(keyValueStorage:) with a test/preview backend.
    private let inMemoryStore = KeyValueStore(keyValueStorage: InMemoryKeyValueStorage())
    private let inMemoryKey = "demo_item"
    private let directKey = "demo_direct_secret"

    init() {
        StorageType.allCases.forEach { refresh(type: $0) }
        refreshDirect()
    }

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
        refresh(type: type)
        return item
    }

    func read(type: StorageType) -> StorageItem? {
        refresh(type: type)
        return stored[type]
    }

    func delete(type: StorageType) {
        if let storage = storage(for: type) {
            storage.delete()
        } else {
            inMemoryStore.remove(using: inMemoryKey)
        }
        refresh(type: type)
    }

    /// Re-reads one backend into the observable snapshot.
    private func refresh(type: StorageType) {
        let item: StorageItem? = storage(for: type).map { $0.get() } ?? inMemoryStore.get(using: inMemoryKey)
        stored[type] = item
    }
}

// MARK: - Direct KeychainWrapper (low-level API)
extension StorageViewModelImpl {
    func saveDirectSecret() -> String {
        let secret = String.random(length: 12)
        KeychainWrapper.standard.set(secret, forKey: directKey)
        refreshDirect()
        return secret
    }

    func readDirectSecret() -> String? {
        refreshDirect()
        return directSecret
    }

    func deleteDirectSecret() {
        KeychainWrapper.standard.removeObject(forKey: directKey)
        refreshDirect()
    }

    private func refreshDirect() {
        directSecret = KeychainWrapper.standard.string(forKey: directKey)
    }
}
