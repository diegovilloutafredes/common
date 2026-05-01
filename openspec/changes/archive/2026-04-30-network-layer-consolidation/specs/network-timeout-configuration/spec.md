## ADDED Requirements

### Requirement: HTTPService exposes a static default timeout interval
`HTTPService` SHALL expose `public static var defaultTimeoutInterval: TimeInterval` initialised to `60`. This value SHALL be applied to every outgoing `URLRequest`'s `timeoutInterval` property before the request is dispatched.

#### Scenario: Default timeout is 60 seconds
- **WHEN** `HTTPService.defaultTimeoutInterval` is read without prior mutation
- **THEN** it returns `60.0`

#### Scenario: Requests use the configured timeout
- **WHEN** `HTTPService.defaultTimeoutInterval = 30` is set and a request is made
- **THEN** the dispatched `URLRequest` has `timeoutInterval == 30`

#### Scenario: Timeout applies to both async and callback paths
- **WHEN** `defaultTimeoutInterval` is set to a custom value
- **THEN** both `HTTPService.request(async throws)` and `HTTPService.request(result:)` dispatched requests reflect that timeout
