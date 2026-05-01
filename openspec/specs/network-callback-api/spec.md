## MODIFIED Requirements

### Requirement: Callback request API is deprecated
The `@discardableResult public static func request<T: Decodable>(_:urlSession:decoder:result:) -> URLSessionTask?` and `upload(multipart:to:decoder:result:)` overloads SHALL be annotated `@available(*, deprecated, renamed: "request(_:urlSession:decoder:)", message: "Use the async throws overload instead.")`. They SHALL continue to compile and behave correctly — deprecation is a warning, not an error.

#### Scenario: Existing callback call site compiles with deprecation warning
- **WHEN** existing code calls the callback overload of `HTTPService.request`
- **THEN** it compiles successfully, emitting a deprecation warning in Xcode

#### Scenario: Callback overload still delivers results
- **WHEN** the deprecated callback overload is called with a valid endpoint
- **THEN** the `result` closure is called on the main thread with the decoded response or a `NetworkError`

#### Scenario: Callback overload returns nil for URLSessionTask
- **WHEN** the deprecated callback overload is called
- **THEN** the return value is `nil` (the underlying async Task is untracked by the caller)

### Requirement: Non-HTTP response failure is reported via callback
The callback `request` path SHALL call `result(.failure(.noDataReceived))` when the server response cannot be cast to `HTTPURLResponse`, instead of silently returning without invoking the result closure.

#### Scenario: Non-HTTP response triggers failure callback
- **WHEN** a `URLSession` returns a non-`HTTPURLResponse` (e.g. from a `file://` URL)
- **THEN** `result(.failure(.noDataReceived))` is called on the main thread

#### Scenario: Normal HTTP response is unaffected
- **WHEN** a standard HTTP response is received
- **THEN** the result closure receives the decoded value or a typed `NetworkError` as before

### Requirement: Response error logic is unified across async and callback paths
A single private `responseError(from:statusCode:) -> NetworkError` helper SHALL be used by both the async and callback paths. The two previously separate implementations (`asyncResponseError` and `defaultResponseHandling`) SHALL be consolidated.

#### Scenario: Error JSON parsing produces identical NetworkError in both paths
- **WHEN** a 4xx response with a JSON body is received via both the async and callback paths
- **THEN** both return a `NetworkError.responseError` with identical `statusCode`, `jsonObject`, and `responseAsData` values
