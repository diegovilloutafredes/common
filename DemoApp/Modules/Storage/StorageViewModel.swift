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

// MARK: - StorageViewModelProtocol
protocol StorageViewModelProtocol: ViewModel {
    var title: String { get }
    func saveToUserDefaults(value: String)
    func saveToFile(value: String)
    func saveToKeychain(value: String)
    func readAll() -> (userDefaults: StorageItem?, file: StorageItem?, keychain: StorageItem?)
    func clearAll()
}

// MARK: - StorageViewModel
final class StorageViewModelImpl: StorageViewModelProtocol {
    let title = "Storage"

    private let userDefaultsKey = "demo_userdefaults"
    private let fileKey = "demo_file"
    private let keychainKey = "demo_keychain"

    private var userDefaultsStore: KeyValueStore { .init(type: .notSecure(.userDefaults)) }
    private var fileStore: KeyValueStore { .init(type: .notSecure(.files)) }
    private var keychainStore: KeyValueStore { .init(type: .secure) }

    func saveToUserDefaults(value: String) {
        let item = StorageItem(value: value, timestamp: .now)
        userDefaultsStore.add(item: (userDefaultsKey, item))
    }

    func saveToFile(value: String) {
        let item = StorageItem(value: value, timestamp: .now)
        fileStore.add(item: (fileKey, item))
    }

    func saveToKeychain(value: String) {
        let item = StorageItem(value: value, timestamp: .now)
        keychainStore.add(item: (keychainKey, item))
    }

    func readAll() -> (userDefaults: StorageItem?, file: StorageItem?, keychain: StorageItem?) {
        let ud: StorageItem? = userDefaultsStore.get(using: userDefaultsKey)
        let fl: StorageItem? = fileStore.get(using: fileKey)
        let kc: StorageItem? = keychainStore.get(using: keychainKey)
        return (ud, fl, kc)
    }

    func clearAll() {
        userDefaultsStore.remove(using: userDefaultsKey)
        fileStore.remove(using: fileKey)
        keychainStore.remove(using: keychainKey)
    }
}
