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

// MARK: - StorageViewModel
final class StorageViewModelImpl: StorageViewModelProtocol {
    let title = "Storage"

    private let keys: [StorageType: String] = [
        .userDefaults: "demo_userdefaults",
        .file: "demo_file",
        .keychain: "demo_keychain"
    ]

    private func store(for type: StorageType) -> KeyValueStore {
        switch type {
        case .userDefaults: .init(type: .notSecure(.userDefaults))
        case .file: .init(type: .notSecure(.files))
        case .keychain: .init(type: .secure)
        }
    }

    @discardableResult
    func save(type: StorageType) -> StorageItem {
        let item = StorageItem(value: type.exampleValue, timestamp: .now)
        store(for: type).add(item: (keys[type]!, item))
        return item
    }

    func read(type: StorageType) -> StorageItem? {
        store(for: type).get(using: keys[type]!)
    }

    func delete(type: StorageType) {
        store(for: type).remove(using: keys[type]!)
    }
}
