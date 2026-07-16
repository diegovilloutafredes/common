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

    var title: String {
        switch self {
        case .userDefaults: "UserDefaults"
        case .file: "FileStorage"
        case .keychain: "Keychain"
        }
    }

    var description: String {
        switch self {
        case .userDefaults: "Best for app preferences and settings. Not encrypted."
        case .file: "Best for documents, cached data, and large payloads."
        case .keychain: "Best for passwords, tokens, and sensitive credentials. Encrypted."
        }
    }

    var exampleValue: String {
        switch self {
        case .userDefaults: "dark_mode: true"
        case .file: "profile_cache.json"
        case .keychain: "eyJhbGciOiJIUzI1NiJ9..."
        }
    }

    var iconName: String {
        switch self {
        case .userDefaults: "gearshape.fill"
        case .file: "doc.fill"
        case .keychain: "lock.shield.fill"
        }
    }

    var color: UIColor {
        switch self {
        case .userDefaults: .systemBlue
        case .file: .systemGreen
        case .keychain: .systemPurple
        }
    }
}

// MARK: - StorageViewModelProtocol
protocol StorageViewModelProtocol: ViewModel {
    var title: String { get }
    func save(type: StorageType) -> StorageItem
    func read(type: StorageType) -> StorageItem?
    func delete(type: StorageType)
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

    private func storage(for type: StorageType) -> DemoItemStorage {
        switch type {
        case .userDefaults: .init(type: .notSecure(.userDefaults))
        case .file: .init(type: .notSecure(.files))
        case .keychain: .init(type: .secure)
        }
    }

    @discardableResult
    func save(type: StorageType) -> StorageItem {
        let item = StorageItem(value: type.exampleValue, timestamp: .now)
        storage(for: type).add(item: item)
        return item
    }

    func read(type: StorageType) -> StorageItem? {
        storage(for: type).get()
    }

    func delete(type: StorageType) {
        storage(for: type).delete()
    }
}
