## ADDED Requirements

### Requirement: HTTPService exposes a static default URLSession
`HTTPService` SHALL expose `public static var defaultSession: URLSession` initialised to `.shared`. Both the async and callback request paths SHALL use this property when no per-call `urlSession` argument is provided.

#### Scenario: Default session is URLSession.shared
- **WHEN** `HTTPService.defaultSession` is read without prior mutation
- **THEN** it returns `URLSession.shared`

#### Scenario: Test overrides the default session
- **WHEN** a test sets `HTTPService.defaultSession = mockSession` before making a request
- **THEN** the request is dispatched through `mockSession`, not `URLSession.shared`

#### Scenario: Per-call session overrides the static default
- **WHEN** `HTTPService.request(resource, urlSession: customSession, ...)` is called with an explicit session
- **THEN** `customSession` is used regardless of `HTTPService.defaultSession`

### Requirement: BaseClient uses HTTPService.defaultSession
`BaseClient` and `AsyncBaseClient` SHALL pass `HTTPService.defaultSession` as the `urlSession` argument when calling `HTTPService.request`, so overriding the static property in tests affects all client subclasses.

#### Scenario: BaseClient subclass request uses injected session
- **WHEN** a test sets `HTTPService.defaultSession = mockSession` and calls a `BaseClient` subclass method
- **THEN** the mock session handles the request
