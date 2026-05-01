## Why

`Loggable.shouldLog` defaults to `true` by reading from Keychain when no entry exists, meaning every production build ships with full logging active unless the operator has explicitly written `false` to Keychain. On a typical screen transition, `viewDidLoad`, `viewWillAppear`, `viewIsAppearing`, `viewDidAppear`, and `viewWillDisappear` each emit a log entry — five Keychain-cache reads and five `print` calls per navigation event. At scale this is measurable overhead on the main thread, and sensitive request/response data is written to the console in release builds. The correct default is no logging in release and opt-in logging in debug.

## What Changes

- Change `Loggable.shouldLog` default from `true` to `false` **in release builds** using `#if DEBUG` compile-time gating
- In `DEBUG` builds, default remains `true` (no change for development workflow)
- Introduce a compile-time `Logger.isCompileTimeEnabled: Bool` constant (`true` in DEBUG, `false` in release) checked before any Keychain access, so the hot lifecycle path incurs zero I/O in production
- **Remove** the Keychain round-trip from the `shouldLog` hot path in release: if `isCompileTimeEnabled == false`, return `false` immediately without touching `_loggableCache` or `_loggableStore`
- Keep the runtime override (`SomeType.shouldLog = true/false`) working in DEBUG for fine-grained control during development
- Add `Logger.forceEnable()` as a DEBUG-only API for test harnesses that need logging in a release-like build configuration

## Capabilities

### New Capabilities

- `compile-time-log-gating`: A `#if DEBUG` compile-time constant that short-circuits all logging before any Keychain or cache access in release builds

### Modified Capabilities

- `logger-default-behaviour`: `shouldLog` default changes from `true` to `false` in non-DEBUG builds; runtime override still works in DEBUG

## Impact

- **`Utils/Logger/Loggable.swift`** — `shouldLog` getter gains a compile-time early return; default Keychain value changes to `false` in release
- **`Utils/Logger/Logger.swift`** — `Logger.log` already calls `guard shouldLog else { return }`; no change needed there if `Loggable` is fixed
- **`Network/HTTPService.swift`** and **`HTTPService+Async.swift`** — `if shouldLog { … }` guards become zero-cost branches in release (compiler eliminates dead code when constant is `false`)
- **Consumer impact**: any consumer that relied on logs appearing in production TestFlight builds will see them disappear. This is the correct behaviour; document in changelog.
- **Debug workflow**: unchanged — logging is on by default in DEBUG, per-type overridable via `SomeType.shouldLog = false`
