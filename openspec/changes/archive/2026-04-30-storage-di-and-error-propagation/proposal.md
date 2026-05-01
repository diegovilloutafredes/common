## Why

The storage layer (`KeyValueStore`, `KeychainWrapper`, `FileStorage`) is built entirely on hardcoded singletons with no injection seam, making it impossible to unit-test any code that reads or writes storage without hitting real Keychain, disk, or UserDefaults. Additionally, every `add`, `get`, and `remove` operation is fire-and-forget — Keychain errors (entitlement failures, device lock, quota exceeded) are silently swallowed, leaving callers with no signal that a write failed. A module-scope `_loggableStore = KeyValueStore(type: .secure)` also triggers a Keychain initialisation at framework import time, contributing to app launch overhead.

## What Changes

- Add a `StorageError` type covering the failure modes of each backend (Keychain, file I/O, serialisation)
- Add `Result`-based overloads to `KeyValueStorage`: `tryAdd(item:) -> Result<Void, StorageError>`, `tryGet<T>(using:) -> Result<T?, StorageError>`, `tryRemove(using:) -> Result<Void, StorageError>` — existing `Void`/`Optional` API is preserved for backwards compatibility
- Introduce a `StorageProvider` protocol that abstracts backend creation, allowing tests to inject an in-memory implementation
- Make `KeyValueStore.StoreType.storage` lazy/configurable so `_loggableStore` does not trigger Keychain access at import time
- Provide an `InMemoryKeyValueStorage` implementation for use in unit tests

## Capabilities

### New Capabilities

- `storage-error-propagation`: Result-based API on `KeyValueStorage` that surfaces backend failures instead of silently discarding them
- `injectable-storage-backend`: `StorageProvider` protocol + `InMemoryKeyValueStorage` enabling dependency injection in tests and preview environments

### Modified Capabilities

<!-- No existing openspec specs — first spec introduction for storage layer -->

## Impact

- **`Storage/KeyValueStore/Protocols/KeyValueStorage.swift`** — new `tryAdd`, `tryGet`, `tryRemove` protocol requirements with default implementations that wrap existing operations
- **`Storage/KeyValueStore/KeyValueStore.swift`** — `StoreType.storage` made lazy; new `StorageProvider` initialiser overload
- **`Storage/KeychainWrapper/KeychainWrapper+KeyValueStorage.swift`** — implement `tryAdd`/`tryGet`/`tryRemove` returning real `OSStatus`-derived errors
- **`Storage/FileStorage/FileStorage.swift`** — implement `tryAdd`/`tryGet`/`tryRemove` returning `Error`-wrapped file I/O failures
- **`Utils/Logger/Loggable.swift`** — defer `_loggableStore` initialisation to avoid Keychain access at import time
- **New file**: `Storage/InMemory/InMemoryKeyValueStorage.swift`
- **New file**: `Storage/Errors/StorageError.swift`
- **Consumer impact**: additive only for existing callers; `Result`-returning overloads are new surface; no breaking changes
