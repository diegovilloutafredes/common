## Why

`HTTPService` maintains two parallel implementations of the same networking logic — a callback-based path (`HTTPService.swift`) and an async/await path (`HTTPService+Async.swift`) — with duplicated response parsing, error construction, and logging across both. The callback path has two correctness bugs: it silently swallows non-HTTP responses (`guard let httpResponse … else { return }` with no result call), and force-unwraps `resource.urlRequest!` inside a logging branch that is reachable only after the guard confirms it is non-nil but is still a fragile dependency on code ordering. Neither path has a URLSession injection seam, so any test that exercises networking hits the real network. There is also no configurable request timeout.

## What Changes

- **Deprecate** the callback-based `HTTPService.request(_:urlSession:decoder:result:)` and `HTTPService.upload(multipart:to:decoder:result:)` overloads with `@available(*, deprecated)` — they are not removed yet, preserving backwards compatibility
- **Route** the callback overloads through the async implementation using `Task { … }` internally, eliminating duplicated parsing logic
- **Fix** the silent non-HTTP response swallow in the callback path: call `result(.failure(.noDataReceived))` instead of bare `return`
- **Remove** the force-unwrap `resource.urlRequest!` in the logging delta branch; use the already-bound `urlRequest` local constant instead
- **Add** `static var defaultSession: URLSession` on `HTTPService` as the injection point for tests (defaults to `.shared`)
- **Add** `static var defaultTimeoutInterval: TimeInterval` on `HTTPService` (defaults to `60`) applied to every `URLRequest` before dispatch
- **Unify** `asyncResponseError` / `defaultResponseHandling` into a single shared function used by both paths

## Capabilities

### New Capabilities

- `network-session-injection`: A `static var defaultSession: URLSession` on `HTTPService` that tests can replace with a mock `URLSession` subclass or `URLProtocol`-backed session
- `network-timeout-configuration`: A `static var defaultTimeoutInterval: TimeInterval` on `HTTPService` applied to every outgoing request

### Modified Capabilities

- `network-callback-api`: Callback overloads are deprecated and re-routed through the async path; the silent non-HTTP swallow and force-unwrap are fixed

## Impact

- **`Network/HTTPService.swift`** — deprecation annotations, bug fixes, internal re-routing to async
- **`Network/HTTPService+Async.swift`** — adds `defaultSession` and `defaultTimeoutInterval` static properties; unifies response-error helper
- **`Network/Client/BaseClient.swift`** and **`AsyncBaseClient.swift`** — pass `HTTPService.defaultSession` instead of `.shared`
- **Consumer impact**: callback API still compiles; deprecation warnings are visible in Xcode but are not errors; no call sites need immediate changes
- **Test impact**: tests can now substitute `HTTPService.defaultSession = mockSession` without method-level overrides
