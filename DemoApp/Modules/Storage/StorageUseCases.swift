//
//  StorageUseCases.swift
//  DemoApp
//

import Common

// MARK: - User

struct User: Storable {
    let name: String
    let age: Int
    let status: Bool
    let date: Date
    let info: [UserInfo]
}

// MARK: - UserInfo

struct UserInfo: Storable {
    let name: String
    let age: Int
    let info: String
}

// MARK: - UserStorage

struct UserStorage: SingleRawValueKeyValueObjectStorage {
    var type: KeyValueStore.StoreType { .secure }

    enum Keys: String { case user }

    func add(item: User) { add(item: (.user, item)) }
    func get() -> User? { get(using: .user) }
    func delete() { remove(using: .user) }
}

// MARK: - UserLocalStorageUseCase

protocol UserLocalStorageUseCase {
    func resolveUser() -> User?
    func saveUser(_ user: User)
    func deleteUser()
}

extension UserLocalStorageUseCase {
    private var storage: UserStorage { .init() }
    func resolveUser() -> User? { storage.get() }
    func saveUser(_ user: User) { storage.add(item: user) }
    func deleteUser() { storage.delete() }
}
