## Context

`Loggable` is a protocol with a static `shouldLog: Bool` backed by a Keychain store and an in-process cache. The default implementation returns `_loggableStore.get(using: key) ?? true` — meaning any type that has never had its logging preference set returns `true`. Every `BaseViewController` subclass conforms transitively (via `BaseCoordinator: Loggable` and `HTTPService: Loggable`), so the five lifecycle log calls per screen and every network request log are active in production with no opt-out required from the consumer.

The `Logger.log(_:)` entry point already has `guard shouldLog else { return }` at the top, so the fix is in making `shouldLog` fast and correct, not in changing Logger's public API.

The Keychain/cache read on `shouldLog` in the hot lifecycle path has two costs:
1. **Cache hit**: dictionary lookup in `_loggableCache` — cheap but runs on every lifecycle event
2. **Cache miss** (first call per type): Keychain read — synchronous, potentially 1–5ms, runs on the main thread

In release builds, the cache miss Keychain read is particularly harmful because it occurs on the first `viewDidLoad` of the app's first screen.

## Goals / Non-Goals

**Goals:**
- Zero Keychain access in release builds for `shouldLog`
- Zero `print` calls in release builds from the framework (Logger, HTTPService, BaseViewController lifecycle)
- DEBUG builds retain current behaviour: logging on by default, per-type runtime override via `shouldLog` setter
- Compile-time constant allows the compiler to eliminate dead logging branches in release (`if shouldLog { … }` becomes unreachable code and is stripped)
- `Logger.forceEnable()` as a DEBUG-only escape hatch for CI/test harnesses

**Non-Goals:**
- Removing the runtime `shouldLog` setter (still useful in DEBUG)
- Replacing `print` with `os_log` or `OSLog` (separate concern, larger change)
- Changing the log format or structure
- Gating DemoApp logging separately from the framework

## Decisions

### D1: Compile-time constant as the primary gate

**Decision:**
```swift
extension Logger {
    #if DEBUG
    public static let isCompileTimeEnabled = true
    #else
    public static let isCompileTimeEnabled = false
    #endif
}
```

Add this as the first check in `Loggable.shouldLog`:
```swift
public static var shouldLog: Bool {
    get {
        guard Logger.isCompileTimeEnabled else { return false }
        // existing cache + Keychain logic
    }
}
```

**Rationale:** `let` constants with `#if DEBUG` are evaluated at compile time. The Swift compiler performs constant-folding and eliminates dead branches behind `if Logger.isCompileTimeEnabled { … }` in release builds. This means zero runtime cost — not even a branch instruction — in production. The Keychain and cache paths are never reached.

**Alternative considered:** Check `#if DEBUG` directly inside every `if shouldLog { … }` block across HTTPService, Logger, etc. Too invasive — 15+ sites to update. The single gate in `shouldLog` covers all of them.

### D2: Default Keychain value changes to `false` in release

**Decision:** Change `_loggableStore.get(using: key) ?? true` to:
```swift
#if DEBUG
let defaultValue = true
#else
let defaultValue = false
#endif
return _loggableStore.get(using: key) ?? defaultValue
```

**Rationale:** Defence in depth. Even if `isCompileTimeEnabled` guard is somehow bypassed (e.g. test builds with custom flags), the Keychain default is now `false` in release. The runtime override still works in DEBUG via the setter.

**Note:** This change only matters in DEBUG builds (release never reaches this line), but it is the correct default regardless.

### D3: Logger.forceEnable() is DEBUG-only

**Decision:**
```swift
#if DEBUG
extension Logger {
    public static func forceEnable() {
        // Set shouldLog = true for all Loggable types that have been registered
        // In practice: set _loggableCache to [:] so next access re-reads from Keychain
        // or set a module-level override flag
    }
}
#endif
```

**Rationale:** CI and snapshot-test harnesses sometimes need to capture logs even in optimised builds. `forceEnable()` provides this without polluting the release binary. The `#if DEBUG` wrapper ensures it is stripped in production.

**Simplification:** `forceEnable()` can simply call `Logger.shouldLog = true` (Logger itself is `Loggable`). For per-type enabling, callers set `HTTPService.shouldLog = true` etc. No global registry needed.

### D4: No OSLog migration in this change

`os_log` / `OSLog` (the unified logging system) would give privacy controls, log levels, and zero-cost release logging. That is a larger architectural change. This change only fixes the default gate; the OSLog migration is a natural follow-up and can be proposed separately.

## Risks / Trade-offs

- **Production builds lose all framework logs.** Developers debugging a production TestFlight build will not see lifecycle or network logs from the framework. → Mitigation: debug builds are unaffected; internal debug builds (Debug configuration) retain full logging. For production debugging, consumers can add their own logging at application layer.
- **`isCompileTimeEnabled` is `public`.** Consumers could use it to gate their own logging, which is acceptable and useful. Document it clearly.
- **Constant-folding depends on the compiler.** Swift's optimiser does eliminate dead code behind `let` constants in release, but this is not a language guarantee — it is a well-established implementation detail of the Swift compiler. If this assumption breaks, the `guard` in `shouldLog` still provides the correct runtime value. → Acceptable risk.
- **`Logger.forceEnable()` only affects Logger, not all Loggable types.** Consumers that want to enable HTTPService logging separately must call `HTTPService.shouldLog = true`. → Document this; it is correct behaviour.

## Migration Plan

1. Add `Logger.isCompileTimeEnabled` with `#if DEBUG`
2. Add the compile-time guard to `Loggable.shouldLog` getter
3. Change default Keychain value to `false` in release
4. Add `Logger.forceEnable()` under `#if DEBUG`
5. Build release configuration — verify zero log output
6. Build debug configuration — verify full log output unchanged
7. Update CHANGELOG

## Open Questions

- Should `isCompileTimeEnabled` live on `Logger` or on `Loggable`? (Recommendation: `Logger` — it is a Logger concern, not a per-type concern.)
- Should we add a `COMMON_LOGGING_ENABLED` Swift compiler flag consumers can set to force-enable in release? (Recommendation: no — if a consumer needs production logging they should use `os_log` at the application layer, not the framework's debug logger.)
