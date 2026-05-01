## 1. Debouncer — Actor Migration

- [x] 1.1 Convert `Debouncer` from a `struct` singleton to `@MainActor final class` (user chose class over actor to avoid Timer/Sendable complexity)
- [x] 1.2 Implement private `_debounce(key:seconds:function:)` instance method; public static wraps it via `shared`
- [x] 1.3 Keep the public `static func debounce(from:id:seconds:function:)` signature synchronous — calls `shared._debounce` directly (MainActor context)
- [x] 1.4 Verify existing call sites compile without modification (no call sites found in framework or DemoApp)
- [x] 1.5 Build framework target; confirmed zero concurrency errors in `Debouncer.swift`

## 2. Logger Cache — OSAllocatedUnfairLock

- [x] 2.1 Replace `nonisolated(unsafe) private var _loggableCache: [String: Bool]` with `private let _loggableCache = OSAllocatedUnfairLock<[String: Bool]>(initialState: [:])`
- [x] 2.2 Update `Loggable.shouldLog` getter to use `_loggableCache.withLock { $0[key] }` for reads
- [x] 2.3 Update `Loggable.shouldLog` setter to use `_loggableCache.withLock { $0[key] = newValue }` for writes
- [x] 2.4 Build framework target; zero concurrency warnings in `Loggable.swift`

## 3. dispatchOnMain — Synchronous-When-Already-Main

- [x] 3.1 Add `if Thread.isMainThread { action(); return }` guard at the top of `dispatchOnMain(_:)` in `Global.swift`
- [x] 3.2 `dispatchOnMainAfter` is intentionally always-async — left unchanged
- [x] 3.3 Build framework target; all `dispatchOnMain` call sites compile

## 4. UIKit Protocol @MainActor Annotations

- [x] 4.1 Add `@MainActor` to `ActivityIndicatorable`
- [x] 4.2 Add `@MainActor` to `AlertPresentable`
- [x] 4.3 Add `@MainActor` to `Dismissable`
- [x] 4.4 Add `@MainActor` to `Navigationable`
- [x] 4.5 Add `@MainActor` to `Presentable`
- [x] 4.6 Add `@MainActor` to `ViewLifecycleable`
- [x] 4.7 Add `@MainActor` to `BaseCoordinator`
- [x] 4.8 Also added `@MainActor` to `AlertRequestable`, `ActivityControllerRequestable`, `DismissRequestable`, `GoBackRequestable`, `Coordinator`, `CollectionViewDataSourceable`, `CollectionViewDelegateable`, `CollectionViewSizeable` to resolve cascade warnings
- [x] 4.9 DemoApp: added `@MainActor` to `HomeViewModel`; marked `HomeWireframe.createModule` `@MainActor`

## 5. BaseClient — Serialised requests Dictionary

- [x] 5.1 Added `private let requestsQueue = DispatchQueue(label: "com.common.baseclient.requests", qos: .utility)`
- [x] 5.2 Changed `public var requests` to computed property backed by `_requests`; getter uses `requestsQueue.sync`, setter uses `requestsQueue.sync` for swap
- [x] 5.3 Old/new value diff and logging runs outside the sync block to avoid holding the lock during I/O
- [x] 5.4 Build confirmed; no data-race warnings on `BaseClient.requests`

## 6. Sendable Annotations on Value Types

- [x] 6.2 Added `Sendable` to `AlertViewType` (all String payloads)
- [x] 6.4 Added `Sendable` to `DismissType` (no associated values)
- [ ] 6.1 Skipped `NetworkError` — `.responseError` carries `[String: Any]` which is not `Sendable`
- [ ] 6.3 Skipped `PopType` — `.to(viewController:)` carries `UIViewController` which is not `Sendable`
- [ ] 6.5 `KeyValueStore.StoreType` — not assessed; deferred to storage layer change

## 7. Verification

- [x] 7.1 Common builds — zero errors, zero concurrency warnings
- [x] 7.2 DemoApp builds — zero errors, zero warnings
- [x] 7.3 All 61 unit tests pass
- [ ] 7.4 `-strict-concurrency=targeted` flag audit — deferred (out of scope for this change)
