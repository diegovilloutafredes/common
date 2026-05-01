# Changelog

## Unreleased

### Added
- **`BaseCollectionViewableViewController<ViewModelType>` — zero-boilerplate collection-view base class.** `BaseViewModelableViewController` no longer unconditionally conforms to `UICollectionViewable`. View controllers that own a `VList` or `HList` subclass `BaseCollectionViewableViewController` instead — all `UICollectionViewDataSource`, `UICollectionViewDelegate`, and `UICollectionViewDelegateFlowLayout` methods are implemented in the base class and delegate to `viewModel as? CollectionViewable`. Footer supplementary views are supported via `onFooterItemReuseIdentifierRequested`/`onFooterItemDataSourceRequested` on `CollectionViewDataSourceable`. Override `bottomInsetForLastCollectionSection()` for VCs above a tab bar. `UIScrollViewDelegate` stubs (`scrollViewDidScroll`, `scrollViewDidEndDecelerating`, `scrollViewDidEndDragging`, `scrollViewDidEndScrollingAnimation`) are provided as `open` methods for subclasses to override selectively.
- **`CollectionViewDataSourceable.onFooterItemDataSourceRequested`/`onFooterItemReuseIdentifierRequested`.** New optional protocol requirements (default implementations return `nil`/`""`) enabling footer supplementary view support through the standard `CollectionViewable` pipeline.
- **`BaseViewController.viewDidDisappear` lifecycle hook.** Mirrors the existing `viewWillDisappear` — logs `["From": Self.self]` and calls `super`. `BaseViewModelableViewController` already forwarded this to `onViewDidDisappear()` on the ViewModel.

### Changed
- **`BaseViewModelableViewController` caches ViewModel role casts.** `asViewLifecycleable` and `asReloadContentRequestable` are now `private var` constants initialised once in `init(viewModel:)` and refreshed via `cacheViewModelRoles()` in `viewModel.didSet`. Eliminates repeated `as?` casts on every lifecycle call.
- **`StorageError` — typed error enum for storage failures.** Covers `encodingFailed`, `decodingFailed`, `keychainError(OSStatus)`, `fileIOError`, and `notFound`. Includes `localizedDescription` mapping common Keychain `OSStatus` codes to human-readable strings.
- **`KeyValueStorage.tryAdd/tryGet/tryRemove` — Result-based storage API.** All three backends (`KeychainWrapper`, `FileStorage`, `InMemoryKeyValueStorage`) now surface real errors via `Result<_, StorageError>`. Default protocol implementations return `.success` for backends that don't override (e.g. `UserDefaults`), preserving backwards compatibility.
- **`InMemoryKeyValueStorage` — in-memory storage backend for tests.** Backed by `[String: Data]` with the same JSON encoding as `FileStorage`. Inject via `KeyValueStore(keyValueStorage: InMemoryKeyValueStorage())`. Call `reset()` between tests.
- **`KeychainWrapper` now surfaces `OSStatus` in `try*` overrides.** `tryGet` distinguishes `errSecItemNotFound` → `.success(nil)` from other Keychain errors → `.failure(.keychainError(status))`.

### Changed
- **`_loggableStore` is now lazily initialised.** Previously a module-scope `let` (which Swift lazily initialises on first access), it is now explicitly deferred inside the `_loggableCache` lock to make the intent clear and guarantee no Keychain access before the first `shouldLog` call.

---

### Changed
- **Callback `HTTPService.request` and `HTTPService.upload` are now deprecated thin wrappers.** Both overloads route through the async `throws` variants via `Task { }` and return `nil`. All response parsing, error construction, and logging now live exclusively in `HTTPService+Async.swift`.
- **`HTTPService.defaultSession` replaces per-call `.shared` default.** Both async and callback paths use `HTTPService.defaultSession` as the default `URLSession`. Override it in tests to inject a `MockURLProtocol`-backed session without changing call sites.
- **`responseError(from:statusCode:)` is now the single error-construction path.** Renamed from `asyncResponseError`; made `internal` so both `HTTPService.swift` and `HTTPService+Async.swift` share it. The old `defaultResponseHandling` helper is removed.
- **Non-HTTP responses now consistently throw `NetworkError.noDataReceived`.** The async path already threw this; the callback path now goes through the same guard via the shared async overload.

### Added
- **`HTTPService.defaultTimeoutInterval: TimeInterval = 60`.** Applied to every outbound `URLRequest` before dispatch. Configurable per-session without subclassing.
- **`Tests/CommonTests/Network/HTTPServiceTests.swift` — 6 new unit tests.** Covers: 200 decode, 4xx `responseError`, 5xx `responseError`, network error → `requestError`, `defaultTimeoutInterval` applied to dispatched request, connection failure → `requestError`.

---

### Changed
- **`Debouncer` is now a `@MainActor final class`.** Replaces the `nonisolated(unsafe)` struct singleton. All timer mutations are main-actor isolated; the public static API is unchanged.
- **`_loggableCache` is now thread-safe.** Replaced `nonisolated(unsafe) var [String: Bool]` with `OSAllocatedUnfairLock<[String: Bool]>`. All reads and writes go through `withLock`.
- **`dispatchOnMain` is synchronous when called from the main thread.** Added a `Thread.isMainThread` fast-path that executes the action immediately instead of enqueueing an async hop.
- **`BaseClient.requests` is now serialised.** Backed by a private `_requests` dictionary accessed via a dedicated serial `DispatchQueue`; eliminates the data race with URLSession background callbacks.
- **`@MainActor` on UIKit-facing protocols.** Added to `ActivityIndicatorable`, `AlertPresentable`, `AlertRequestable`, `ActivityControllerRequestable`, `Dismissable`, `DismissRequestable`, `Navigationable`, `Presentable`, `ViewLifecycleable`, `GoBackRequestable`, `Coordinator`, `CollectionViewDataSourceable`, `CollectionViewDelegateable`, `CollectionViewSizeable`, and `BaseCoordinator`. Prevents actor-isolation mismatches in Swift 6 strict concurrency.

### Added
- **`DismissType: Sendable`** — enables passing dismiss strategies across concurrency boundaries.
- **`AlertViewType: Sendable`** — enables passing alert types across concurrency boundaries.

---

### Changed
- **Logger is now silent in Release builds.** `Logger.isCompileTimeEnabled` is `false` in non-DEBUG configurations, causing `shouldLog` to return `false` immediately without any Keychain or cache access. All lifecycle logs (`viewDidLoad`, `viewWillAppear`, etc.) and network request logs produce no console output in production builds.
- `Loggable.shouldLog` defaults to `true` in DEBUG (unchanged) and `false` in Release (previously `true` in all configurations).
- `Loggable.shouldLog` setter is a no-op in Release builds.

### Added
- `Logger.isCompileTimeEnabled: Bool` — public compile-time constant consumers can use to gate their own logging.
- `Logger.forceEnable()` — DEBUG-only escape hatch that sets `Logger.shouldLog = true`; not available in Release builds.
