## Context

Common is an iOS 16+ Swift framework distributed as an SPM package and XCFramework. It is used across 5+ production apps. The codebase predates Swift 6 strict concurrency. Key problem areas identified in the framework review:

1. `Debouncer`: A `struct` with a mutable `[String: Timer]` dict hidden behind a `nonisolated(unsafe) private static var`. Any concurrent `debounce()` call from a background queue (e.g. triggered by a scroll event off-main) produces a data race.
2. `_loggableCache`: Module-scope `nonisolated(unsafe) private var [String: Bool]`. Written by `Loggable.shouldLog.set` which can be called from any thread. Read by `shouldLog.get` on the first log call per type.
3. UIKit protocols (`ActivityIndicatorable`, `AlertPresentable`, `Dismissable`, `Navigationable`, `Presentable`, `ViewLifecycleable`): No `@MainActor`. Consumer code that conforms from a non-isolated context (e.g. an actor, a background Task) suppresses the compiler's UIKit-thread checks.
4. `BaseClient.requests`: `public var [String: URLSessionTask]` on a class. URLSession completion handlers fire on a private queue; the `didSet` observer reads `oldValue` and `requests` — both potential data races.
5. `dispatchOnMain`: Always `DispatchQueue.main.async`. When already on main, the block runs one run-loop cycle later, which can cause single-frame layout delays.

## Goals / Non-Goals

**Goals:**
- Zero Swift 6 strict-concurrency warnings across all changed files
- Eliminate the two verified data races (Debouncer, _loggableCache)
- `@MainActor` on all UIKit-facing protocols in `Protocols/UI/`
- Thread-safe `BaseClient.requests` without breaking the public API
- `dispatchOnMain` is a no-op dispatch when already on main thread
- `Sendable` conformance on simple value types that cross concurrency boundaries

**Non-Goals:**
- Migrating the entire framework to `async/await` (that is a separate, larger change)
- Enabling `-strict-concurrency=complete` for the whole module (too broad; this change targets the identified files only)
- Changing any public observable behaviour (debounce timing, log output, network semantics)

## Decisions

### D1: Debouncer — `actor` vs. serial `DispatchQueue`

**Decision:** Replace the singleton struct with an `actor`.

**Rationale:** An `actor` is the idiomatic Swift 6 solution. It serialises all access automatically without manual queue management. The public `static func debounce(...)` becomes an `async` method if called from async context, or can be called with `Task { await Debouncer.shared.debounce(...) }` from sync contexts. Timer scheduling happens on the actor's executor.

**Alternative considered:** A `private static let queue = DispatchQueue(label: "com.common.debouncer", qos: .userInitiated)` wrapping all mutations. This avoids `async` propagation but is GCD-based and fights Swift 6 rather than embracing it.

**Constraint:** The existing call-site signature `Debouncer.debounce(from:id:seconds:function:)` is synchronous. We preserve it via a `Task { await ... }` wrapper inside the static method so call sites don't change.

### D2: `_loggableCache` — actor vs. `OSAllocatedUnfairLock`

**Decision:** Use `OSAllocatedUnfairLock<[String: Bool]>` (available iOS 16+, which matches the deployment target).

**Rationale:** The cache is a simple read-modify-write on a dictionary. An `OSAllocatedUnfairLock` is the lowest-overhead primitive for this pattern and avoids making `shouldLog` an `async` property (which would cascade into every `if shouldLog { }` guard across the networking and logging code). This is a pure Swift 6 Sendable primitive.

**Alternative considered:** `actor LoggableCache`. Would require `await` at every `shouldLog` access — all `if shouldLog {` blocks in HTTPService, Logger, etc. would need to become `async` or use `Task`. Too invasive.

### D3: `@MainActor` on UIKit protocols

**Decision:** Add `@MainActor` to the protocol declarations themselves, not to individual methods.

**Rationale:** These protocols are entirely UI-thread concerns. Marking the protocol `@MainActor` enforces at the conformance site that the implementor must also be `@MainActor` (or use `nonisolated` for individual methods). This is the highest-leverage annotation point.

**Consumer impact:** Conforming types that are not already `@MainActor` will get a compiler error. For `UIViewController` subclasses this is a no-op (UIKit types are already `@MainActor`). For coordinators (`BaseCoordinator: NSObject`) the class itself needs `@MainActor` or each protocol conformance needs `@MainActor` on the extension.

**Decision:** Add `@MainActor` to `BaseCoordinator` class declaration. It only ever runs navigation code on the main thread; this is the correct annotation.

### D4: `BaseClient.requests` serialisation

**Decision:** Make `requests` internal to the class and serialise mutations through a private serial `DispatchQueue`.

**Rationale:** The `requests` dict is `public var` — changing its type to actor-isolated would be ABI-breaking. A private queue serialises the `didSet` observer and any external mutations. Public getters remain synchronous.

**Alternative:** Make `BaseClient` an `actor`. Would break all call sites that access `requests` synchronously. Too invasive.

### D5: `dispatchOnMain` — inline check

**Decision:** Add `if Thread.isMainThread { action(); return }` before the `async` dispatch.

**Rationale:** Simple, zero-overhead when on main, backwards-compatible. The only risk is re-entrancy (synchronous execution within an already-executing main-thread block), which is the desired behaviour (UIKit already does this pattern internally).

## Risks / Trade-offs

- **`@MainActor` on protocols is source-breaking** for consumer code that conforms from non-isolated contexts. → Mitigation: Document in CHANGELOG. Consumer apps in this monorepo are also under our control and can be updated.
- **`actor` Debouncer introduces `async` at the static wrapper layer.** Internally `Task { await ... }` means the timer may be scheduled slightly later than synchronous dispatch. → Mitigation: Debounce is inherently delayed; one async hop (microseconds) is imperceptible next to the debounce interval (100ms+).
- **`OSAllocatedUnfairLock` requires iOS 16+** — already the framework's minimum, so no regression.
- **`dispatchOnMain` synchronous path changes run-loop semantics.** Code that relied on async dispatch to defer execution will now execute synchronously. → Mitigation: All framework call sites are `[weak self]` guards with no re-entrancy risk.

## Migration Plan

1. Apply file-by-file changes (each file is independently compilable)
2. Build framework target — resolve any new warnings
3. Build DemoApp — resolve consumer-side `@MainActor` propagation
4. Run unit tests (currently minimal, but build must pass)
5. Each consuming app in the monorepo: build → fix `@MainActor` annotations on their coordinators/VMs

## Open Questions

- Should `BaseCoordinator` itself gain `@MainActor`, or only its protocol extension conformances? (Recommendation: the class declaration — keeps it simple and correct.)
- Should `Loggable.shouldLog` setter be made `nonisolated` to avoid the lock in pure-test contexts? (Recommendation: no — the lock is cheap and correctness matters more.)
