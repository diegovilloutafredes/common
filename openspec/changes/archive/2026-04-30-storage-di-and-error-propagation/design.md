## Context

`KeyValueStore` is a facade over three backends: `UserDefaults.standard`, `FileStorage.shared`, and `KeychainWrapper.standard`. All three are accessed via `StoreType.storage`, a computed property that returns the singleton directly. The protocol `KeyValueStorage` has `add(item:) -> Void`, `get<T>(using:) -> T?`, and `remove(using:) -> Void` — no error path exists at any level. `FileStorage` uses `try?` internally (errors discarded), and `KeychainWrapper` returns `OSStatus` codes that are never surfaced to callers.

The module-scope `private let _loggableStore = KeyValueStore(type: .secure)` in `Loggable.swift` initialises a `KeychainWrapper.standard` at the point the `Common` module is first imported — before `application(_:didFinishLaunchingWithOptions:)` runs. On first launch on a new device, Keychain provisioning may not yet be complete.

Testability: any class that uses `KeyValueStore` directly must hit real storage backends in tests. There is no seam to substitute an in-memory store.

## Goals / Non-Goals

**Goals:**
- `KeyValueStorage` gains `tryAdd`, `tryGet`, `tryRemove` returning `Result` types
- All three backends implement the `try*` variants with real error information
- `InMemoryKeyValueStorage` provides a test/preview backend with no side effects
- `_loggableStore` is lazily initialised (first log call, not import time)
- `KeyValueStore` can be constructed with any `KeyValueStorage` conformer (already exists via `init(keyValueStorage:)`) — document this as the DI seam
- `StorageError` is a typed, `Sendable` enum covering all failure modes

**Non-Goals:**
- Making the existing `add`/`get`/`remove` methods throw (breaking change)
- Async storage API (separate concern)
- Migration of all existing callers to `Result`-based API
- Replacing `UserDefaults.standard` with a custom UserDefaults suite

## Decisions

### D1: Additive `try*` overloads, not replacement

**Decision:** Add `tryAdd(item:) -> Result<Void, StorageError>`, `tryGet<T>(using:) -> Result<T?, StorageError>`, `tryRemove(using:) -> Result<Void, StorageError>` as new protocol requirements with default implementations that call the existing `Void`/`Optional` variants and return `.success`.

**Rationale:** Changing existing signatures is a breaking change affecting all consumers. The `try*` prefix is a clear signal of the richer API. Callers that need error information opt in; existing callers are unaffected.

**Default implementations in extension:** The protocol extension provides a fallback that calls `add`/`get`/`remove` and wraps in `.success`, so existing conformers (e.g. `UserDefaults`) get correct defaults without modification. Backends that can surface real errors (Keychain, FileStorage) override the `try*` methods explicitly.

### D2: `StorageError` as a typed enum

**Decision:**
```swift
public enum StorageError: Error, Sendable {
    case encodingFailed(Error)
    case decodingFailed(Error)
    case keychainError(OSStatus)
    case fileIOError(Error)
    case notFound
}
```

**Rationale:** Typed errors allow callers to pattern-match on the specific failure. `OSStatus` codes from Keychain are passed through directly so callers can distinguish `errSecItemNotFound` from `errSecAuthFailed`. `Sendable` conformance allows `StorageError` to cross actor boundaries.

### D3: `InMemoryKeyValueStorage` backed by `[String: Data]`

**Decision:** `InMemoryKeyValueStorage` stores `Data` values keyed by `String`, using `JSONEncoder`/`JSONDecoder` matching the existing serialisation strategy. It is a `class` (reference semantics) so the same instance can be injected into multiple components and mutations are shared.

**Rationale:** Using `Data` as the value type mirrors exactly what `KeychainWrapper` and `FileStorage` store on disk, so serialisation round-trips are identical. This maximises test fidelity.

**Alternative considered:** `[String: Any]` dictionary. Avoids encoding overhead but allows tests to bypass serialisation bugs, reducing fidelity.

### D4: Defer `_loggableStore` initialisation

**Decision:** Replace `private let _loggableStore = KeyValueStore(type: .secure)` with a lazy initialisation pattern using a `nonisolated(unsafe) private var` initialised on first access, wrapped in the same `OSAllocatedUnfairLock` introduced by the Swift 6 concurrency change.

**Rationale:** Aligns with the concurrency hardening work. The lock already guards `_loggableCache`; the store initialisation can be gated behind the same lock's `withLock` block on first read.

**Constraint:** This decision depends on the `concurrency-safe-logger-cache` spec from the `swift-6-concurrency-hardening` change. If that change lands first, the store can be lazily initialised inside the lock. If this change lands first, a standalone lazy pattern (`DispatchQueue.once` or `lazy var` via a wrapper) must be used.

### D5: `StorageProvider` protocol — thin wrapper, not factory

**Decision:** Do NOT introduce a `StorageProvider` protocol factory. Instead, document `KeyValueStore.init(keyValueStorage:)` as the explicit DI seam. Tests construct `KeyValueStore(keyValueStorage: InMemoryKeyValueStorage())` directly.

**Rationale:** A factory protocol adds abstraction without benefit — the existing memberwise initialiser already accepts any `KeyValueStorage` conformer. Adding a factory layer makes the API harder to discover. The proposal mentioned `StorageProvider` but the simpler path achieves the same testability goal.

## Risks / Trade-offs

- **Default `try*` implementations always return `.success`** for backends that don't override them. A caller using `tryAdd` on `UserDefaults` will never receive a failure even if UserDefaults is full. → Mitigation: document clearly; `UserDefaults` failures are uncommon and OS-handled.
- **`InMemoryKeyValueStorage` is a class** — shared state in tests requires explicit reset between test cases. → Mitigation: provide a `reset()` method and document in the class header.
- **Lazy `_loggableStore` adds complexity** if the concurrency change hasn't landed yet. → Mitigation: the tasks section sequences this dependency explicitly.
- **`OSStatus` in `StorageError.keychainError`** requires callers to know Keychain status codes. → Mitigation: add a computed `localizedDescription` that maps common codes to human-readable strings.

## Migration Plan

1. Add `StorageError.swift` and `InMemoryKeyValueStorage.swift`
2. Add `try*` methods to `KeyValueStorage` protocol with default `.success` implementations
3. Implement `try*` in `KeychainWrapper+KeyValueStorage.swift` using real `OSStatus`
4. Implement `try*` in `FileStorage.swift` using `try`/`catch`
5. Defer `_loggableStore` init in `Loggable.swift`
6. Update `KeyValueStore` to expose `InMemoryKeyValueStorage` via its public `init(keyValueStorage:)` seam (no change needed — already exists)
7. Add unit tests for `InMemoryKeyValueStorage` round-trips and `StorageError` cases

## Open Questions

- Should `UserDefaults` gain a `tryAdd` override that checks `UserDefaults.didChangeNotification`? (Recommendation: no — over-engineering for a rare failure mode.)
- Should `StorageError` be nested inside `KeyValueStorage` namespace? (Recommendation: top-level public type for discoverability.)
