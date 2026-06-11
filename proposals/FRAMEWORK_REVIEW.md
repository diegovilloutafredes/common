# Common Framework — Full Architecture Review

> **Original date:** 2026-04-30  
> **Last revalidated:** 2026-06-11 (statuses updated after `framework-quality-tail`)  
> **Scope:** All 547 Swift source files (~16k LOC) across Architecture, Views, ViewControllers, Protocols, Network, Storage, Extensions, Utils, ResultBuilders  
> **Severity key:** 🔴 Critical (correctness/safety) · 🟠 High (SOLID/concurrency) · 🟡 Medium (performance/testability) · 🟢 Low (style/polish)

---

## 1. Architecture Layer

### BaseCoordinator (`Architecture/BaseCoordinator.swift`)

| # | Severity | Finding |
|---|----------|---------|
| A1 | ✅ | ~~**No automatic child cleanup.**~~ **Fixed by `coordinator-child-lifecycle`.** Added `weak var parent: BaseCoordinator?` wired by `addChild`; `open func finish()` auto-removes the child from its parent then fires `onPerformed`. Re-entrancy guard prevents double-fire. `removeChild` is now identity-based, not type-based. |
| A2 | 🟠 | **`addChild` silently deduplicates by removing first.** Calling `addChild` twice with the same coordinator removes-then-adds it, resetting its position in the array. This is implicit and surprising; intent should be explicit. |
| A3 | 🟢 | `BaseCoordinator` inherits `NSObject` to satisfy `UIGestureRecognizerDelegate` in `BaseViewController`. These are separate conformances — coupling through inheritance is unnecessary. |

### BaseViewModelableViewController (`ViewControllers/Base/BaseViewModelableViewController.swift`)

| # | Severity | Finding |
|---|----------|---------|
| A4 | ✅ | ~~**SRP violation: every VC conforms to `UICollectionViewable` unconditionally.**~~ **Fixed by `base-viewmodelable-viewcontroller-srp`.** `BaseCollectionViewableViewController` is the opt-in base for VCs that own a `VList`/`HList`; `BaseViewModelableViewController` no longer carries collection-view boilerplate. |
| A5 | ✅ | ~~**Domain logic in base class: `insetForSectionAt` hardcodes `closestTabBarHeight + 4` for the last section.**~~ **Fixed.** `BaseCollectionViewableViewController` exposes `bottomInsetForLastCollectionSection()` (default `.zero`); subclasses above a tab bar opt in explicitly. |
| A6 | ✅ | ~~`asCollectionViewable`, `asViewLifecycleable`, `asReloadContentRequestable` are computed properties that re-cast on every call.~~ **Fixed by `framework-quality-tail`.** `BaseViewModelableViewController` caches `_asViewLifecycleable`/`_asReloadContentRequestable` on init + `viewModel` `didSet`; `BaseCollectionViewableViewController` now caches `asCollectionViewable` the same way. |
| A7 | ✅ | ~~`viewForSupplementaryElementOfKind` only handles `elementKindSectionHeader`. Footer kind is silently ignored.~~ **Fixed.** Both header and footer kinds are handled via `onFooterItemReuseIdentifierRequested`/`onFooterItemDataSourceRequested`. |

### BaseViewController (`ViewControllers/Base/BaseViewController.swift`)

| # | Severity | Finding |
|---|----------|---------|
| A8 | ✅ | ~~**Missing `viewDidDisappear` override.**~~ **Fixed.** `BaseViewController` now overrides `viewDidDisappear` and calls `super`. |
| A9 | ✅ | ~~**Extra intermediate UIView in every VC.**~~ **Re-classified as intentional.** The container is required so that `setConstraints { $0.snap(to: $1.safeAreaLayoutGuide) }` fires against `self.view` (which receives UIKit's safe-area updates). Without it, cells land under the navigation bar and become non-hittable. Documented in `Libraries/CLAUDE.md` → "Known Gotchas → `UIViewBuilder` and `loadView`". |
| A10 | 🟢 | `prefersHomeIndicatorAutoHidden: Bool { true }` applies globally to all VCs. Controllers where the indicator should be visible (media, games) must override this explicitly. |

### ViewModelable / ViewModelSettable (`Protocols/UI/ViewModelable.swift`)

| # | Severity | Finding |
|---|----------|---------|
| A11 | 🟠 | **Force-cast on `ViewModelHolder`:** `self.viewModel = viewModel as! ViewModelType`. The cast is structurally correct in current usage, but it's a runtime crash waiting for a wiring mistake. A guard + assertionFailure in DEBUG + silent no-op in release would be safer. |

---

## 2. Concurrency & Swift 6 Posture

| # | Severity | Finding | Location |
|---|----------|---------|---------|
| C1 | ✅ | ~~**`Debouncer.shared` is a mutable struct behind `nonisolated(unsafe)`.**~~ **Fixed by `swift-6-concurrency-hardening`.** `Debouncer` is now a `@MainActor final class`; `timers` dictionary is main-actor isolated. | `Utils/Debouncer.swift` |
| C2 | ✅ | ~~**`_loggableCache: [String: Bool]` at module scope with `nonisolated(unsafe)`.**~~ **Fixed by `swift-6-concurrency-hardening`.** Replaced with `OSAllocatedUnfairLock<[String: Bool]>`; all reads/writes use `withLock`. | `Utils/Logger/Loggable.swift` |
| C3 | ✅ | ~~**`dispatchOnMain` always dispatches async.**~~ **Fixed by `swift-6-concurrency-hardening`.** Added `if Thread.isMainThread { action(); return }` fast path — same-thread calls are now synchronous. | `Global.swift` |
| C4 | ✅ | ~~**No `@MainActor` on UIKit-facing protocols.**~~ **Fixed by `swift-6-concurrency-hardening`.** `@MainActor` added to `ActivityIndicatorable`, `AlertPresentable`, `AlertRequestable`, `ActivityControllerRequestable`, `Dismissable`, `DismissRequestable`, `Navigationable`, `Presentable`, `ViewLifecycleable`, `GoBackRequestable`, `Coordinator`, `CollectionViewDataSourceable`, `CollectionViewDelegateable`, `CollectionViewSizeable`, and `BaseCoordinator`. | `Protocols/UI/`, `Architecture/` |
| C5 | ✅ | ~~**`BaseClient.requests` is `public var`** — no synchronisation.~~ **Fixed by `swift-6-concurrency-hardening`.** Backed by `_requests` with a private serial `DispatchQueue`; reads use `sync`, writes swap under `sync` then log outside the lock. | `Network/Client/BaseClient.swift` |
| C6 | 🟡 | **27** `nonisolated(unsafe)` usages remain (revalidated 2026-05-14). The two mutable-state cases (C1, C2) are fixed. Remaining usages are UInt8 associated-object keys (address-only, never mutated — safe) and `NSCache`-backed formatters (thread-safe by design). The new `AppFontRegistry.primaryFamily` (introduced with the typography system) also uses `nonisolated(unsafe)` for the same reason: a write-once registration set during scene setup, read thereafter. | Various |

---

## 3. Networking Layer

| # | Severity | Finding |
|---|----------|---------|
| N1 | ✅ | ~~**Force-unwrap in production logging path.**~~ **Fixed by `network-layer-consolidation`.** Callback path is now a thin `Task { }` wrapper over the async overload; the old logging block with `resource.urlRequest!` is gone entirely. | `Network/HTTPService.swift` |
| N2 | ✅ | ~~**`shouldLog` defaults to `true` from Keychain.**~~ **Fixed by `logger-production-gating`.** `Logger.isCompileTimeEnabled` is `false` in Release; `shouldLog` returns `false` immediately with no Keychain access. See Ut2. | `Utils/Logger/Loggable.swift` |
| N3 | ✅ | ~~**Significant code duplication between `HTTPService.swift` and `HTTPService+Async.swift`.**~~ **Fixed by `network-layer-consolidation`.** Callback overloads are now deprecated thin wrappers over the async path via `Task { }`. All response parsing, error construction, and logging live solely in `HTTPService+Async.swift`. | `Network/HTTPService.swift` |
| N4 | ✅ | ~~**No URLSession injection seam.**~~ **Fixed by `network-layer-consolidation`.** Added `HTTPService.defaultSession: URLSession` static property; both the default parameter and `MockURLProtocol`-based tests override it. 6 new unit tests exercise the injection seam. | `Network/HTTPService+Async.swift` |
| N5 | ✅ | ~~**No request timeout configuration.**~~ **Fixed by `network-layer-consolidation`.** Added `HTTPService.defaultTimeoutInterval: TimeInterval = 60`; applied to every outbound `URLRequest` before dispatch. Test verifies the value is reflected in the captured request. | `Network/HTTPService+Async.swift` |
| N6 | ✅ | ~~**Silent swallow of non-HTTP responses in callback path.**~~ **Fixed by `network-layer-consolidation`.** Callback path routes through the async overload which already throws `NetworkError.noDataReceived` for non-HTTP responses. Both paths are now consistent. | `Network/HTTPService.swift` |
| N7 | 🟢 | `Date.asMilliseconds` used for timing delta. `CFAbsoluteTimeGetCurrent()` is lower overhead. |

---

## 4. Storage Layer

| # | Severity | Finding |
|---|----------|---------|
| S1 | ✅ | ~~**All three backends are singletons with no injection seam.**~~ **Fixed by `storage-di-and-error-propagation`.** `InMemoryKeyValueStorage` provides a test backend; `KeyValueStore(keyValueStorage:)` is the DI seam. Tests construct `KeyValueStore(keyValueStorage: InMemoryKeyValueStorage())` without hitting Keychain or disk. | `Storage/InMemory/InMemoryKeyValueStorage.swift` |
| S2 | ✅ | ~~**All storage operations are silent on failure.**~~ **Fixed by `storage-di-and-error-propagation`.** `tryAdd`, `tryGet`, `tryRemove` added to `KeyValueStorage` with real `StorageError` surfacing for Keychain (`OSStatus`), FileStorage (`Error`-wrapped), and InMemory backends. | `Storage/Protocols/KeyValueStorage.swift`, `Storage/Errors/StorageError.swift` |
| S3 | ✅ | ~~**`_loggableStore` triggers Keychain init at import time.**~~ **Fixed by `storage-di-and-error-propagation`.** `_loggableStore` is now lazily initialised inside the `_loggableCache` lock on first `shouldLog` access, not at module import. | `Utils/Logger/Loggable.swift` |
| S4 | ✅ | ~~Thread safety of `FileStorage` and `KeychainWrapper` is not documented.~~ **Fixed by `framework-quality-tail`.** Both types now carry `- Important:` DocC noting `FileStorage.shared` is an unsynchronized mutable static and that `KeychainWrapper` read-modify-write sequences are not atomic. |

---

## 5. Declarative UI DSL (ResultBuilders + Views)

| # | Severity | Finding |
|---|----------|---------|
| U1 | 🟠 | **`UIViewBuildable.mainView` is a computed `var` with no enforcement of single-call contract.** The protocol documentation says "called exactly once," but nothing enforces this at compile time. A caller can access `mainView` twice, producing two separate view trees — the second orphaned and leaking. Enforcement requires `lazy var` in implementations, which is a convention, not a language guarantee. |
| U2 | 🟡 | **Partial.** `UIViewBuilder.buildOptional` now `assertionFailure`s in DEBUG when the optional is nil, steering callers away from the bad pattern, but the release path still returns an empty placeholder `UIView`. `ArrayBuilder.buildExpression(_ item: T?) -> [T]` provides a leak-free path for `UIView?` inside `VStack`/`HStack` literals (nil values drop with no reserved layout space). Outstanding: replace the release-path placeholder with a true no-op return when the result builder allows it. |
| U3 | 🟡 | **`@UIViewsBuilder views: () -> [UIView] = {[]}` evaluates eagerly.** All subviews are instantiated at VStack/HStack init time. Complex hierarchies built conditionally incur full allocation even when not displayed. |
| U4 | 🟡 | **`VStack(alignment: .center)` collapses views with no intrinsic width**. This is a known footgun. A runtime warning in DEBUG builds would prevent silent layout bugs. |
| U5 | 🟢 | `Stack.swift` base class is public. Consumer code could instantiate `Stack` directly rather than `VStack`/`HStack`, bypassing the axis config. Making `Stack` `open` for subclassing but not instantiable directly would be cleaner. |

---

## 6. Protocol Design

| # | Severity | Finding |
|---|----------|---------|
| P1 | 🟠 | **`Dismissable` and `AlertPresentable` depend on `UIApplication.shared.topMostViewController`** — a global mutable walk of the window hierarchy. This is fragile (multi-scene, extensions), not testable, and makes these protocols effectively singletons. The `Dismissable where Self: Navigationable` override improves this but `AlertPresentable` always uses the global walk. |
| P2 | 🟠 | **Partial (state bugs fixed by `framework-quality-tail`).** The UITextField implementation now stashes and restores the previous `rightView`/`rightViewMode` (double-start keeps the original stash), and the UIView implementation records pre-hidden subviews and restores exactly that state on stop. Outstanding (design-level): four distinct implementations from one protocol remains the opposite of ISP — one name, four behaviours. |
| P3 | 🟡 | **`AlertPresentable.applyDefaultAlertStyle` uses KVC** (`setValue(_:forKey:"attributedTitle")`). This is an undocumented private UIKit API that Apple has historically broken. A custom alert (which already exists via `CustomAlertViewController`) should replace it. |
| P4 | 🟡 | **`BaseModuleDelegate` composition includes `ActivityControllerRequestable`** but this is rarely needed (share sheets). It inflates the coordinator conformance requirement unnecessarily. |
| P5 | 🟢 | `Withable` and `ValueWithable` serve the same purpose with different signatures. The distinction is subtle and rarely used in production code. |

---

## 7. Utilities

| # | Severity | Finding |
|---|----------|---------|
| Ut1 | ✅ | ~~**`Debouncer` is a global singleton with mutable `[String: Timer]` behind `nonisolated(unsafe)`.**~~ **Fixed by `swift-6-concurrency-hardening`.** Same finding as C1 — `Debouncer` is now a `@MainActor final class`; `timers` dictionary is main-actor isolated. |
| Ut2 | ✅ | ~~**`Logger` logging defaults to ON in production**~~ **Fixed by `logger-production-gating`.** `Logger.isCompileTimeEnabled` gates all logging at compile time; Release builds return `false` immediately from `shouldLog` with no Keychain access. Debug default remains `true`. |
| Ut3 | ✅ | ~~**`Logger` sorts dictionary keys alphabetically**~~ **Fixed by `framework-quality-tail`.** `Logger.log` takes `KeyValuePairs<String, Any>` and prints in call-site order; a deprecated `[String: Any]` overload remains for dictionary-variable callers (order unspecified). |
| Ut4 | 🟡 | **`Global.swift` has duplicate doc comment line** (`/// Global functions` appears twice) and uses free global functions. A `Dispatch` namespace (enum) would prevent accidental name collisions with consumer code. |
| Ut5 | 🟢 | `CameraManager`, `LocalAuthenticationManager`, `AppleLoginManager` are not injectable. They hold no state and could be protocols with default implementations (UseCase pattern the project uses elsewhere). |

---

## 8. Extensions Layer

| # | Severity | Finding |
|---|----------|---------|
| E1 | 🟡 | **419 extension files, all `public`.** There is no internal/public split or `@_spi` grouping. Domain-specific helpers (e.g. `String+RUTUtilities`, CVPixelBuffer, CMSampleBuffer, ARSCNView) are framework-level public API but are relevant only to specific consumer verticals. This bloats the public ABI surface. |
| E2 | 🟡 | **No test coverage for extensions.** `Tests/CommonTests/` contains stubs only. Extensions like `UIImage+AverageColor`, `CGRect+IsClose`, `String+IsValidEmail`, `String+RUTUtilities` have logic that is easy to unit test and fragile to modify without tests. |
| E3 | ✅ | ~~**`as! UIButton` force-cast in `UITextField+AddToggleVisibilityButton.swift:33`.**~~ **Fixed by `framework-quality-tail`.** `guard let` replaces the force-cast, and the `onTap` closure captures `self` weakly — removing a retain cycle (text field → rightView → button → closure → text field). |
| E4 | 🟢 | `Array+Coordinator.swift` provides `getFirst(_:)` and `removeAll(_:)` by type. These are useful but the names shadow `Array.first` semantics. `first(ofType:)` and `removeAll(ofType:)` would be cleaner. |

---

## 9. Testability

| # | Severity | Finding |
|---|----------|---------|
| T1 | 🟡 | **Substantially addressed (was 🔴).** As of 2026-06-11 the suite spans 22 test suites covering Storage DI, the network injection seam, `HTTPService` headers/timeouts, image-loader cache & cancellation, coordinator child lifecycle, BVMVC SRP, the typography system, RUT validation, email validation (via `FieldsValidatorTests`), and — added by `framework-quality-tail` — date parsing/formatting, image-processing extensions, `ActivityIndicatorable` state restoration, logger ordering, and font registration errors. Remaining gaps are minor (assorted small extensions). |
| T2 | ✅ | ~~**Storage singletons make unit testing impossible without swizzling.**~~ **Fixed by `storage-di-and-error-propagation`.** See S1 — `InMemoryKeyValueStorage` provides the test seam. |
| T3 | ✅ | ~~**`URLSession.shared` default in `HTTPService` requires real network in tests.**~~ **Fixed by `network-layer-consolidation`.** See N4 — `HTTPService.defaultSession` is the injection point; `MockURLProtocol`-based tests override it. |
| T4 | 🟡 | **`BaseCoordinator` has no protocol.** It's a concrete class. Consumer coordinators that want to be mocked in tests must subclass, not substitute. A `CoordinatorType` protocol (or use the existing `Coordinator` protocol more broadly) would decouple. |

---

## 10. API Surface & Versioning

| # | Severity | Finding |
|---|----------|---------|
| V1 | 🟡 | **`EmptyResult<Failure>` duplicates `Result<Void, Failure>`.** Swift's standard `Result.success(())` covers this. `EmptyResult` adds a bespoke type consumers must learn. |
| V2 | 🟡 | **`CompletionHandler = Action?` (optional closure typedef).** Optional type aliases are confusing: `CompletionHandler` is `(() -> Void)?` — an optional function. Makes call sites read as `completion: nil` when the caller wants no completion. A non-optional `() -> Void` with a default `{}` argument is cleaner. |
| V3 | 🟢 | `InOutHandler<T> = (T) -> T` is named inconsistently with Swift naming conventions (no type parameter in the name is fine; the "InOut" prefix implies `inout` parameter which this isn't). `Transformer<T>` or `Mapping<T>` would be clearer. |

---

## Top 5 Proposals (OpenSpec)

The following findings are grouped into five focused, shippable proposals ranked by impact:

| Priority | Proposal | Findings Covered |
|----------|----------|-----------------|
| **P1** | ✅ ~~**Swift 6 Concurrency Hardening**~~ **Done** (`swift-6-concurrency-hardening`) | C1, C2, C3, C4, C5, C6 |
| **P2** | ~~**BaseViewModelableViewController SRP Refactor**~~ Partial — A4 done (`base-viewmodelable-viewcontroller-srp`); A5–A9 open | A4 ✅, A5, A6, A7, A8, A9 |
| **P3** | ✅ ~~**Storage Layer: DI Seams + Error Propagation**~~ **Done** (`storage-di-and-error-propagation`) | S1, S2, S3, T2 |
| **P4** | ✅ ~~**Debouncer & Logger Safety**~~ **Done** (`swift-6-concurrency-hardening` + `logger-production-gating`) | Ut1, Ut2, C1, C2 |
| **P5** | ✅ ~~**Network Layer: Consolidation + Testability**~~ **Done** (`network-layer-consolidation`) | N1, N2, N3, N4, N5, N6 |
