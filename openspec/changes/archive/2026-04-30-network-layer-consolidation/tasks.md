## 1. Bug Fixes (no API changes)

- [x] 1.1 In `HTTPService.swift`, fix the silent non-HTTP swallow: change `guard let httpResponse = response as? HTTPURLResponse else { return }` to call `dispatchOnMain { result(.failure(.noDataReceived)) }` before returning
- [x] 1.2 In `HTTPService.swift`, remove the force-unwrap `resource.urlRequest!` in the timing-delta log block; replace with the already-bound `urlRequest` local constant
- [x] 1.3 Build `Common` scheme — zero errors, confirm the two changed lines compile correctly

## 2. Unified Response Error Helper

- [x] 2.1 In `HTTPService+Async.swift`, rename `asyncResponseError(from:statusCode:)` to `responseError(from:statusCode:)` and make it `internal` (not `private`) so it is visible across files in the same module
- [x] 2.2 In `HTTPService.swift`, delete `defaultResponseHandling(data:statusCode:result:)` entirely
- [x] 2.3 Update both the callback `switch statusCode { default: }` branch and the async `default:` branch to call the unified `responseError(from:statusCode:)` helper and handle the return value appropriately (callback: `dispatchOnMain { result(.failure(error)) }`; async: `throw error`)
- [x] 2.4 Build `Common` scheme — zero errors

## 3. Static Injection Properties

- [x] 3.1 Add `public static var defaultSession: URLSession = .shared` to `HTTPService` in `HTTPService+Async.swift`
- [x] 3.2 Add `public static var defaultTimeoutInterval: TimeInterval = 60` to `HTTPService` in `HTTPService+Async.swift`
- [x] 3.3 In the async `request` method, apply `defaultTimeoutInterval` to the `URLRequest` before dispatch: `var mutableRequest = urlRequest; mutableRequest.timeoutInterval = HTTPService.defaultTimeoutInterval`
- [x] 3.4 Update the async `request` default parameter from `urlSession: URLSession = .shared` to `urlSession: URLSession = HTTPService.defaultSession`
- [x] 3.5 Build `Common` scheme — zero errors

## 4. Deprecate and Re-route Callback Overloads

- [x] 4.1 Add `@available(*, deprecated, message: "Use the async throws overload instead.")` to the callback `request` overload in `HTTPService.swift`
- [x] 4.2 Add `@available(*, deprecated, message: "Use the async throws overload instead.")` to the callback `upload` overload in `HTTPService.swift`
- [x] 4.3 Replace the callback `request` body with a `Task { do { let value: T = try await request(...); result(.success(value)) } catch let e as NetworkError { result(.failure(e)) } catch { result(.failure(.requestError(error))) } }` and return `nil`
- [x] 4.4 Replace the callback `upload` body analogously, routing through the async `upload` overload
- [x] 4.5 Remove the now-unused `dataTask.resume()` / `URLSessionTask` creation from the callback path
- [x] 4.6 Build `Common` — zero errors; confirm deprecation warnings appear for internal call sites

## 5. Update BaseClient and AsyncBaseClient

- [x] 5.1 In `Network/Client/BaseClient.swift` and `ClientProtocol.swift`, update any `HTTPService.request` calls that pass `urlSession: .shared` to use `urlSession: HTTPService.defaultSession`
- [x] 5.2 In `Network/Client/AsyncBaseClient.swift` and `AsyncClientProtocol.swift`, do the same
- [x] 5.3 Build `Common` — zero errors

## 6. Network Tests

- [x] 6.1 Create `Tests/CommonTests/Network/HTTPServiceTests.swift`
- [x] 6.2 Implement a `MockURLProtocol` that intercepts requests and returns configurable `(Data, HTTPURLResponse)` or errors
- [x] 6.3 In `setUp`, set `HTTPService.defaultSession = URLSession(configuration: mockConfig)`; in `tearDown`, restore `HTTPService.defaultSession = .shared`
- [x] 6.4 Test: successful 200 response decodes into expected `Decodable` type
- [x] 6.5 Test: 4xx response returns `NetworkError.responseError` with correct `statusCode`
- [x] 6.6 Test: non-HTTP response returns `NetworkError.noDataReceived` (covers the fixed silent-swallow bug)
- [x] 6.7 Test: network error (simulated connection failure) returns `NetworkError.requestError`
- [x] 6.8 Test: `defaultTimeoutInterval` is reflected in the dispatched `URLRequest.timeoutInterval`

## 7. Verification

- [x] 7.1 Build `Common` scheme — zero errors
- [x] 7.2 Build `DemoApp` scheme — zero errors (deprecation warnings expected; not errors)
- [x] 7.3 Run unit tests — all pass including new network tests
- [x] 7.4 Confirm `HTTPService.request(result:)` deprecation warning appears in DemoApp networking call sites
