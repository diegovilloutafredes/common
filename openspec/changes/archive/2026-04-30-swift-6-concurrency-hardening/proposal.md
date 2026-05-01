## Why

The Common framework ships with multiple data races under Swift 6 strict concurrency: a mutable `Debouncer` singleton and a module-scope `_loggableCache` dictionary are both marked `nonisolated(unsafe)` and written from arbitrary threads with no serialisation. UIKit-facing protocols carry no `@MainActor` annotation, causing consumer code to generate concurrency warnings (and errors under `-strict-concurrency=complete`). These issues block adopters from enabling Swift 6 and introduce real crash risk in multithreaded apps.

## What Changes

- Replace `Debouncer`'s `nonisolated(unsafe) private static var shared` + mutable `[String: Timer]` with an `actor`-based or `DispatchQueue`-serialised implementation
- Replace `nonisolated(unsafe) private var _loggableCache: [String: Bool]` (module-scope mutable dict) with thread-safe storage (actor or `DispatchQueue`)
- Annotate `ActivityIndicatorable`, `AlertPresentable`, `Dismissable`, `Navigationable`, `Presentable` and `ViewLifecycleable` with `@MainActor`
- Serialise `BaseClient.requests` dictionary mutations (currently a public `var` on a class, written from URLSession background callbacks)
- Fix `dispatchOnMain` to check `Thread.isMainThread` and dispatch synchronously when already on main, avoiding unnecessary one-cycle delay
- Annotate value-type public API (`NetworkError`, `AlertViewType`, `PopType`, `DismissType`, `StoreType`) with `Sendable` where applicable

## Capabilities

### New Capabilities

- `concurrency-safe-debouncer`: Thread-safe debounce utility using actor isolation or serial queue, replacing the racy global singleton
- `concurrency-safe-logger-cache`: Thread-safe per-type logging flag cache, replacing the module-scope `nonisolated(unsafe)` dictionary
- `main-actor-ui-protocols`: All UIKit-facing protocols annotated with `@MainActor` so consumers get compiler enforcement of UI-thread requirements

### Modified Capabilities

<!-- No existing spec-level requirement changes — this is a correctness/safety fix with no observable behavioural change for consumers operating on the main thread. -->

## Impact

- **`Utils/Debouncer.swift`** — full rewrite of implementation (public API signature unchanged)
- **`Utils/Logger/Loggable.swift`** — `_loggableCache` storage mechanism changes
- **`Protocols/UI/ActivityIndicatorable.swift`**, `AlertPresentable.swift`, `Dismissable.swift`, `Navigationable.swift`, `Presentable.swift`, `ViewLifecycleable.swift` — `@MainActor` added
- **`Network/Client/BaseClient.swift`** — `requests` serialisation
- **`Global.swift`** — `dispatchOnMain` guard
- **Consumer impact**: Adding `@MainActor` to protocols is source-breaking for any consumer that conforms from a non-`@MainActor` context. Consumers will need to add `@MainActor` to their conforming types or use `MainActor.run {}` at call sites. This is the correct fix; the old code was incorrectly unsuppressed.
