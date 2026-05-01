## Context

`HTTPService.swift` (callback) and `HTTPService+Async.swift` (async) are two complete, parallel implementations of the same pipeline: build request → execute → log timing → parse response → decode or extract error JSON → call back on main. The two files share roughly 70% of their logic but neither calls the other. Changes to error handling, decoding strategy, or logging must be applied twice and are frequently missed, causing drift.

Specific bugs in the callback path:
1. `guard let httpResponse = response as? HTTPURLResponse else { return }` — the `else` branch returns without calling `result`, leaving the caller hanging indefinitely if the response is not HTTP.
2. `Logger.log(["Request delta of \(resource.urlRequest!)": …])` — force-unwrap inside the `shouldLog` branch. The surrounding guard at the top of `request` only returns early; by the time we reach the logging block, the `urlRequest` local constant is already bound. The force-unwrap on `resource.urlRequest` is therefore redundant and dangerous if the function is ever refactored.

Neither path uses a shared `URLSession`. Both hard-code `.shared` as the default. There is no static injection point.

## Goals / Non-Goals

**Goals:**
- Single source of truth for response parsing and error construction
- Callback overloads are deprecated and delegate to the async path via `Task`
- Both bugs (silent swallow, force-unwrap) are fixed
- `HTTPService.defaultSession: URLSession` and `HTTPService.defaultTimeoutInterval: TimeInterval` are static, settable properties
- Timeout is applied to every `URLRequest` via `timeoutInterval` property before dispatch

**Non-Goals:**
- Removing the callback API (breaking change; deferred to a future major version)
- Migrating `BaseClient` subclasses to async (consumer-side change)
- Adding retry logic, request interception, or middleware
- Replacing `URLSession` with a third-party networking library

## Decisions

### D1: Callback path delegates to async via `Task`

**Decision:** Replace the callback `request` body with:
```swift
Task {
    do {
        let value: T = try await request(resource, urlSession: urlSession, decoder: decoder)
        result(.success(value))
    } catch let error as NetworkError {
        result(.failure(error))
    } catch {
        result(.failure(.requestError(error)))
    }
}
```
The `@discardableResult URLSessionTask?` return type becomes `nil` (the task is untracked). Callers that stored the task to cancel it will lose cancellation support.

**Cancellation trade-off:** The callback API never had a reliable cancellation story — `BaseClient.requests` tracked tasks by string key, but callers rarely used this. Under the new routing, the `Task` can be cancelled via the enclosing `Task` hierarchy, which is strictly better for async-aware callers. Synchronous callers that need cancellation should migrate to the async API and hold a `Task` handle directly.

**Rationale:** Eliminates duplication at the cost of one async hop per callback request (microseconds). The deprecation warning signals callers to migrate.

**Alternative considered:** Keep both paths separate but extract a shared `parseResponse` function. This eliminates the logic duplication without the async-routing overhead but still requires maintaining two call sites. Chosen approach is simpler long-term.

### D2: `defaultSession` and `defaultTimeoutInterval` as static vars on `HTTPService`

**Decision:**
```swift
public static var defaultSession: URLSession = .shared
public static var defaultTimeoutInterval: TimeInterval = 60
```
Applied in the async `request` method as:
```swift
var mutableRequest = urlRequest
if mutableRequest.timeoutInterval == 60 { // only override if still at URLRequest default
    mutableRequest.timeoutInterval = HTTPService.defaultTimeoutInterval
}
```

**Rationale:** Static vars are the simplest injection seam for a `public enum` type that has no instances. Tests set `HTTPService.defaultSession = mockSession` in `setUp()` and restore in `tearDown()`. This is idiomatic for UIKit-era frameworks.

**Thread safety:** Static `var` on a `public enum` is not actor-isolated. Mutation is intended only in test setup (single-threaded), not at runtime. Document this constraint.

**Alternative considered:** Pass `session` and `timeout` per-call (already supported via the existing `urlSession:` parameter). The `default` static property supplements rather than replaces per-call overrides.

### D3: Unify response-error helper

**Decision:** Rename `asyncResponseError(from:statusCode:)` to `responseError(from:statusCode:)` and delete `defaultResponseHandling` (the callback-era version). Both paths use the single helper. Move it to a private extension on `HTTPService` shared by both files.

**Rationale:** `defaultResponseHandling` calls `dispatchOnMain { result(...) }` which is callback-specific. The unified helper returns a `NetworkError` value; the caller decides whether to dispatch or throw. Cleaner separation.

### D4: Fix silent swallow — emit `.noDataReceived`

**Decision:** Change:
```swift
guard let httpResponse = response as? HTTPURLResponse else { return }
```
to:
```swift
guard let httpResponse = response as? HTTPURLResponse else {
    dispatchOnMain { result(.failure(.noDataReceived)) }
    return
}
```

**Rationale:** The async path already throws `.noDataReceived` for this case. Parity is restored. The case is rare in production (only occurs with non-HTTP schemes like `file://` or `data://`) but can silently deadlock a callback chain in tests.

### D5: Remove force-unwrap in logging

**Decision:** Replace `resource.urlRequest!` in the delta logging block with `urlRequest` (the local constant already bound at the top of the function).

**Rationale:** Pure correctness fix. Zero behaviour change.

## Risks / Trade-offs

- **Callback callers lose the `URLSessionTask?` return value.** The return becomes `nil`. Callers that called `.cancel()` on the returned task will silently stop cancelling. → Mitigation: document in deprecation message; cancellation via `Task` handle is the async-path replacement.
- **One extra async hop per callback request.** `Task { await ... }` schedules on the cooperative thread pool, then the `dispatchOnMain` in the wrapper calls back on main. Net latency impact is sub-millisecond. → Acceptable given the deprecation trajectory.
- **`defaultSession` is a global mutable static.** Tests that run in parallel and mutate it will interfere. → Mitigation: document as test-setup-only; recommend `XCTestCase.setUp`/`tearDown` discipline.

## Migration Plan

1. Fix bugs first (silent swallow, force-unwrap) — safe, no API changes
2. Add `defaultSession` and `defaultTimeoutInterval` static properties
3. Unify `responseError` helper
4. Route callback overloads through async, mark `@available(*, deprecated)`
5. Update `BaseClient`/`AsyncBaseClient` to use `defaultSession`
6. Add network tests using `URLProtocol`-backed mock session
7. Build and test

## Open Questions

- Should `defaultTimeoutInterval` only apply when `URLRequest.timeoutInterval` is at the system default (60s), or always override? (Recommendation: always override — a framework-level default should be authoritative.)
- Should the deprecation message suggest a migration path? (Recommendation: yes — include `"Use the async throws overload instead."` in the deprecated message.)
