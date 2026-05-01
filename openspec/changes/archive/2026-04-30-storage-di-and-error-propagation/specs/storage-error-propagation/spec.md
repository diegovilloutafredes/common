## ADDED Requirements

### Requirement: KeyValueStorage exposes Result-based write API
`KeyValueStorage` SHALL provide `tryAdd(item:) -> Result<Void, StorageError>` as a protocol requirement with a default implementation that returns `.success` for backends that do not surface errors.

#### Scenario: Successful write on any backend
- **WHEN** `tryAdd(item:)` is called and the underlying store writes successfully
- **THEN** `.success` is returned

#### Scenario: Keychain write fails due to auth failure
- **WHEN** `tryAdd(item:)` is called on a Keychain-backed store and the device is locked
- **THEN** `.failure(.keychainError(errSecInteractionNotAllowed))` is returned

#### Scenario: File write fails due to disk full
- **WHEN** `tryAdd(item:)` is called on a file-backed store and disk is full
- **THEN** `.failure(.fileIOError(underlyingError))` is returned

### Requirement: KeyValueStorage exposes Result-based read API
`KeyValueStorage` SHALL provide `tryGet<T: Storable>(using key: String) -> Result<T?, StorageError>` as a protocol requirement. A `.success(nil)` result means the key was not found; `.failure` means the backend itself errored.

#### Scenario: Key exists and decodes correctly
- **WHEN** `tryGet(using:)` is called for a key that was previously written
- **THEN** `.success(value)` is returned with the decoded value

#### Scenario: Key does not exist
- **WHEN** `tryGet(using:)` is called for a key that has never been written
- **THEN** `.success(nil)` is returned (not a failure)

#### Scenario: Data exists but decoding fails
- **WHEN** stored data cannot be decoded into the requested type `T`
- **THEN** `.failure(.decodingFailed(underlyingDecodingError))` is returned

### Requirement: KeyValueStorage exposes Result-based delete API
`KeyValueStorage` SHALL provide `tryRemove(using key: String) -> Result<Void, StorageError>`.

#### Scenario: Successful deletion
- **WHEN** `tryRemove(using:)` is called for an existing key
- **THEN** `.success` is returned and the item is no longer retrievable

#### Scenario: Keychain deletion fails
- **WHEN** `tryRemove(using:)` is called on a Keychain-backed store and the OS rejects the operation
- **THEN** `.failure(.keychainError(status))` is returned

### Requirement: StorageError is a typed Sendable enum
`StorageError` SHALL be a `public enum` conforming to `Error` and `Sendable`, with cases covering all failure modes of the three storage backends.

#### Scenario: Keychain OSStatus is preserved
- **WHEN** a Keychain operation fails with `OSStatus` code `errSecAuthFailed`
- **THEN** the returned `StorageError` is `.keychainError(errSecAuthFailed)` and callers can pattern-match on the status

#### Scenario: Encoding failure wraps the underlying error
- **WHEN** a `Storable` value cannot be JSON-encoded
- **THEN** the returned `StorageError` is `.encodingFailed(underlyingEncodingError)`

### Requirement: Existing Void/Optional API is preserved unchanged
The existing `add(item:)`, `get<T>(using:)`, and `remove(using:)` methods on `KeyValueStorage` SHALL remain with identical signatures and behaviour. No call sites require modification.

#### Scenario: Existing callers compile without changes
- **WHEN** code that calls `store.add(item: (key, value))` is compiled against the updated framework
- **THEN** it compiles and behaves identically to before
