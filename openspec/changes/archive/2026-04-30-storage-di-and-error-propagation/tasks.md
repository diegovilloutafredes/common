## 1. StorageError Type

- [x] 1.1 Create `Common/Storage/Errors/StorageError.swift` with `public enum StorageError: Error, Sendable` covering cases: `encodingFailed(Error)`, `decodingFailed(Error)`, `keychainError(OSStatus)`, `fileIOError(Error)`, `notFound`
- [x] 1.2 Add a `var localizedDescription: String` on `StorageError` that maps common `OSStatus` codes (`errSecItemNotFound`, `errSecAuthFailed`, `errSecInteractionNotAllowed`) to readable strings

## 2. KeyValueStorage Protocol — try* API

- [x] 2.1 Add `func tryAdd(item: KeyValue<Storable>) -> Result<Void, StorageError>` to `KeyValueStorage` protocol with a default implementation that calls `add(item:)` and returns `.success`
- [x] 2.2 Add `func tryGet<T: Storable>(using key: String) -> Result<T?, StorageError>` to `KeyValueStorage` protocol with a default implementation that calls `get(using:)` and wraps the optional in `.success`
- [x] 2.3 Add `func tryRemove(using key: String) -> Result<Void, StorageError>` to `KeyValueStorage` protocol with a default implementation that calls `remove(using:)` and returns `.success`
- [x] 2.4 Build framework — confirm existing conformers (`UserDefaults`, `KeychainWrapper`, `FileStorage`, `KeyValueStore`) compile with the new protocol requirements via default implementations

## 3. KeychainWrapper — Real Error Implementation

- [x] 3.1 In `KeychainWrapper+KeyValueStorage.swift`, override `tryAdd(item:)` to capture the `OSStatus` returned by `SecItemAdd`/`SecItemUpdate` and return `.failure(.keychainError(status))` on non-`errSecSuccess` results
- [x] 3.2 Override `tryGet<T>(using:)` to distinguish `errSecItemNotFound` (return `.success(nil)`) from other errors (return `.failure(.keychainError(status))`) and decoding failures (return `.failure(.decodingFailed(error))`)
- [x] 3.3 Override `tryRemove(using:)` to surface non-`errSecSuccess` status codes as `.failure(.keychainError(status))`

## 4. FileStorage — Real Error Implementation

- [x] 4.1 In `FileStorage.swift`, override `tryAdd(item:)` to replace `try?` with a real `do/catch` and return `.failure(.encodingFailed(error))` or `.failure(.fileIOError(error))` on failure
- [x] 4.2 Override `tryGet<T>(using:)` to catch file read errors as `.failure(.fileIOError(error))` and decoding errors as `.failure(.decodingFailed(error))`; return `.success(nil)` when the file does not exist
- [x] 4.3 Override `tryRemove(using:)` to catch file deletion errors as `.failure(.fileIOError(error))`

## 5. InMemoryKeyValueStorage

- [x] 5.1 Create `Common/Storage/InMemory/InMemoryKeyValueStorage.swift` as `public final class InMemoryKeyValueStorage: KeyValueStorage`
- [x] 5.2 Implement internal `var store: [String: Data] = [:]` using `JSONEncoder`/`JSONDecoder` for serialisation, matching the encoding strategy of `FileStorage`
- [x] 5.3 Implement `add(item:)`, `get<T>(using:)`, `remove(using:)` delegating to the dictionary store
- [x] 5.4 Implement `tryAdd`, `tryGet`, `tryRemove` with real error surfacing (encoding/decoding failures)
- [x] 5.5 Add `public func reset()` that clears the internal dictionary
- [x] 5.6 Document `init()` as the test/preview entry point and note that `KeyValueStore(keyValueStorage: InMemoryKeyValueStorage())` is the DI pattern

## 6. Deferred _loggableStore Initialisation

- [x] 6.1 In `Loggable.swift`, replace `private let _loggableStore = KeyValueStore(type: .secure)` with a lazy initialisation pattern: wrap in a computed accessor that initialises once (using `OSAllocatedUnfairLock` if the Swift 6 change has landed, otherwise a `DispatchQueue`-guarded `Optional<KeyValueStore>`)
- [x] 6.2 Verify that importing `Common` in a unit test with no Keychain entitlements does not crash or produce `OSStatus` errors before any logging occurs

## 7. Unit Tests

- [x] 7.1 Create `Tests/CommonTests/Storage/InMemoryKeyValueStorageTests.swift`
- [x] 7.2 Test write → read round-trip for `String`, `Int`, `Bool`, and a `Codable` struct
- [x] 7.3 Test `remove` clears the key
- [x] 7.4 Test `reset()` clears all keys
- [x] 7.5 Test `tryGet` returns `.success(nil)` for a missing key
- [x] 7.6 Test `StorageError.keychainError` `localizedDescription` for `errSecItemNotFound` and `errSecAuthFailed`

## 8. Verification

- [x] 8.1 Build `Common` scheme — zero errors
- [x] 8.2 Build `DemoApp` scheme — zero errors (no call-site changes required)
- [x] 8.3 Run unit tests — all pass including new storage tests
- [x] 8.4 Confirm no Keychain access occurs during module import in a test with no entitlements
