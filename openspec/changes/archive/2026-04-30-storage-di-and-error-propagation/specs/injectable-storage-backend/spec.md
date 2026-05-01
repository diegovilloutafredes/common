## ADDED Requirements

### Requirement: InMemoryKeyValueStorage is a KeyValueStorage conformer
The framework SHALL provide `InMemoryKeyValueStorage`, a `public final class` conforming to `KeyValueStorage`, that stores values in an in-process dictionary with no side effects on disk, Keychain, or UserDefaults.

#### Scenario: Write and read round-trip
- **WHEN** `add(item: ("key", value))` is called followed by `get(using: "key")`
- **THEN** the same value is returned, encoded and decoded through `JSONEncoder`/`JSONDecoder`

#### Scenario: Remove clears the key
- **WHEN** `remove(using: "key")` is called after a write
- **THEN** `get(using: "key")` returns `nil`

#### Scenario: No file system or Keychain access
- **WHEN** `InMemoryKeyValueStorage` is used in a test that has no Keychain entitlements
- **THEN** no `OSStatus` errors are thrown and no files are created on disk

### Requirement: InMemoryKeyValueStorage can be reset between tests
`InMemoryKeyValueStorage` SHALL expose a `reset()` method that clears all stored entries, allowing test isolation without creating a new instance.

#### Scenario: Reset clears all keys
- **WHEN** `reset()` is called after several writes
- **THEN** `get(using:)` returns `nil` for every previously written key

### Requirement: KeyValueStore accepts any KeyValueStorage at init
`KeyValueStore.init(keyValueStorage:)` SHALL be the documented dependency-injection seam. Any `KeyValueStorage` conformer, including `InMemoryKeyValueStorage`, SHALL be passable at this init point.

#### Scenario: Test constructs KeyValueStore with InMemoryKeyValueStorage
- **WHEN** test code writes `let store = KeyValueStore(keyValueStorage: InMemoryKeyValueStorage())`
- **THEN** all `add`/`get`/`remove` calls operate on the in-memory store with no real backend access

### Requirement: _loggableStore is lazily initialised
The module-scope `_loggableStore` used by `Loggable` SHALL NOT initialise its `KeychainWrapper` backend at framework import time. Initialisation SHALL be deferred to the first read or write of a `shouldLog` value.

#### Scenario: Importing Common does not access Keychain
- **WHEN** the `Common` module is imported and no logging has occurred
- **THEN** no Keychain API calls are made during the import sequence

#### Scenario: First shouldLog access triggers store init
- **WHEN** `SomeType.shouldLog` is read for the first time
- **THEN** the Keychain store is initialised at that point and the correct value is returned
