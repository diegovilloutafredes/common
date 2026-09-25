//
//  KeyValueStoreResultForwardingTests.swift
//

import XCTest
@testable import Common

/// `KeyValueStore` must answer the Result-based API with its backend's own results: a backend
/// failure reaches the caller unchanged instead of the protocol defaults' unconditional success.
final class KeyValueStoreResultForwardingTests: XCTestCase {

    private struct Token: Storable, Equatable {
        let value: String
    }

    /// Fails every Result-based call, each method with its own status so a mis-wired forward shows.
    private final class FailingBackend: KeyValueStorage {
        func add(item: KeyValue<Storable>) {}
        func get<T: Storable>(using key: String) -> T? { nil }
        func remove(using key: String) {}
        func tryAdd(item: KeyValue<Storable>) -> Result<Void, StorageError> { .failure(.keychainError(errSecInteractionNotAllowed)) }
        func tryGet<T: Storable>(using key: String) -> Result<T?, StorageError> { .failure(.keychainError(errSecAuthFailed)) }
        func tryRemove(using key: String) -> Result<Void, StorageError> { .failure(.keychainError(errSecDuplicateItem)) }
    }

    /// Answers `tryGet` with a value its fire-and-forget `get` never returns.
    private final class TryGetOnlyBackend: KeyValueStorage {
        func add(item: KeyValue<Storable>) {}
        func get<T: Storable>(using key: String) -> T? { nil }
        func remove(using key: String) {}
        func tryGet<T: Storable>(using key: String) -> Result<T?, StorageError> { .success(Token(value: "from tryGet") as? T) }
    }

    private func keychainStatus(_ result: Result<some Any, StorageError>) -> OSStatus? {
        guard case .failure(.keychainError(let status)) = result else { return nil }
        return status
    }

    func test_tryAdd_returnsTheBackendFailure() {
        let store = KeyValueStore(keyValueStorage: FailingBackend())
        XCTAssertEqual(keychainStatus(store.tryAdd(item: ("token", Token(value: "x")))), errSecInteractionNotAllowed)
    }

    func test_tryGet_returnsTheBackendFailure() {
        let store = KeyValueStore(keyValueStorage: FailingBackend())
        let result: Result<Token?, StorageError> = store.tryGet(using: "token")
        XCTAssertEqual(keychainStatus(result), errSecAuthFailed)
    }

    func test_tryRemove_returnsTheBackendFailure() {
        let store = KeyValueStore(keyValueStorage: FailingBackend())
        XCTAssertEqual(keychainStatus(store.tryRemove(using: "token")), errSecDuplicateItem)
    }

    func test_tryGet_passesTheBackendSuccessValueThrough() {
        let store = KeyValueStore(keyValueStorage: TryGetOnlyBackend())
        let result: Result<Token?, StorageError> = store.tryGet(using: "token")
        XCTAssertEqual(try result.get(), Token(value: "from tryGet"))
    }
}
