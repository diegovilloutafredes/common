//
//  HTTPService+Async.swift
//

import Foundation

// MARK: - HTTPService (Async)
extension HTTPService {

    /// URLSession used for all requests. Override in tests via `HTTPService.defaultSession = mockSession`.
    public static var defaultSession: URLSession = .shared

    /// Timeout applied to every outbound request that doesn't set its own. Defaults to 60 s (same as URLRequest's
    /// built-in default).
    ///
    /// A request sets its own timeout when it comes from an `Endpoint` that declares `timeoutInterval`, or when it is
    /// a `URLRequest` whose `timeoutInterval` isn't URLRequest's built-in 60 s. A `URLRequest` explicitly set to 60 s
    /// therefore gets this value too; declare the timeout on an endpoint when it must be exact.
    public static var defaultTimeoutInterval: TimeInterval = 60

    /// `URLRequest`'s own default timeout, which a raw request that sets none still carries.
    private static let builtInTimeoutInterval: TimeInterval = 60

    /// Performs an HTTP request asynchronously and decodes the response to a specified type.
    ///
    /// - Parameters:
    ///   - resource: The resource to request.
    ///   - urlSession: The URLSession to use. Defaults to `HTTPService.defaultSession`.
    ///   - decoder: The JSONDecoder to use. Defaults to snake_case conversion.
    /// - Returns: The decoded response of type `T`.
    /// - Throws: `NetworkError` on failure, or `CancellationError` if the enclosing Task is cancelled.
    public static func request<T: Decodable>(
        _ resource: URLRequestConvertible,
        urlSession: URLSession = HTTPService.defaultSession,
        decoder: JSONDecoder = .init().keyDecodingStrategy(.convertFromSnakeCase)
    ) async throws -> T {
        try await send(resource, urlSession: urlSession, decoder: decoder)
    }

    /// Uploads a multipart request asynchronously and decodes the response to a specified type.
    ///
    /// - Parameters:
    ///   - multipart: The multipart data to upload.
    ///   - resource: The resource to upload to.
    ///   - decoder: The JSONDecoder to use. Defaults to snake_case conversion.
    /// - Returns: The decoded response of type `T`.
    /// - Throws: `NetworkError` on failure, or `CancellationError` if the enclosing Task is cancelled.
    public static func upload<T: Decodable>(
        multipart: MultipartRequest,
        to resource: URLRequestConvertible,
        decoder: JSONDecoder = .init().keyDecodingStrategy(.convertFromSnakeCase)
    ) async throws -> T {
        try await upload(multipart: multipart, to: resource, urlSession: HTTPService.defaultSession, decoder: decoder)
    }

    /// Uploads a multipart request asynchronously through the given session and decodes the response.
    ///
    /// - Parameters:
    ///   - multipart: The multipart data to upload.
    ///   - resource: The resource to upload to.
    ///   - urlSession: The URLSession to use. Defaults to `HTTPService.defaultSession`.
    ///   - decoder: The JSONDecoder to use. Defaults to snake_case conversion.
    /// - Returns: The decoded response of type `T`.
    /// - Throws: `NetworkError` on failure, or `CancellationError` if the enclosing Task is cancelled.
    public static func upload<T: Decodable>(
        multipart: MultipartRequest,
        to resource: URLRequestConvertible,
        urlSession: URLSession = HTTPService.defaultSession,
        decoder: JSONDecoder = .init().keyDecodingStrategy(.convertFromSnakeCase)
    ) async throws -> T {
        try await send(resource, multipart: multipart, urlSession: urlSession, decoder: decoder)
    }

    /// The core `request` and `upload` share. It receives the original resource, so everything the resource declares
    /// is still known when the request is prepared.
    static func send<T: Decodable>(
        _ resource: URLRequestConvertible,
        multipart: MultipartRequest? = nil,
        urlSession: URLSession,
        decoder: JSONDecoder
    ) async throws -> T {
        guard var mutableRequest = resource.urlRequest else {
            throw NetworkError.invalidRequest(resource)
        }

        if let multipart {
            if shouldLog { Logger.log(["multipart": multipart]) }
            mutableRequest.setValue(multipart.contentTypeHeaderValue, forHTTPHeaderField: "Content-Type")
            mutableRequest.httpBody = multipart.httpBody
        }

        mutableRequest.timeoutInterval = timeoutInterval(for: resource, preparedRequest: mutableRequest)

        let beforeRequestTime = Date.asMilliseconds
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await urlSession.data(for: mutableRequest)
        } catch is CancellationError {
            throw CancellationError()
        } catch where Task.isCancelled {
            // URLSession reports a cancelled Task as URLError(.cancelled); the documented contract is
            // CancellationError. Keyed on the Task, not the code: .cancelled also covers session
            // invalidation and cancelled auth challenges, which are failures, not the caller's cancel.
            throw CancellationError()
        } catch {
            if shouldLog { Logger.log(["error": error]) }
            throw NetworkError.requestError(error)
        }

        if shouldLog {
            let delta = Date.asMilliseconds - beforeRequestTime
            Logger.log(["Request delta of \(mutableRequest)": "\(delta)ms"])
            Logger.log(mutableRequest, data: data, response: response)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noDataReceived
        }

        let statusCode = httpResponse.statusCode

        switch statusCode {
        case 200...299:
            // Decided by the requested type: a model still needs a body, and JSONDecoder rejects empty data.
            if let empty = EmptyResponse() as? T { return empty }
            do {
                return try decoder.decode(T.self, from: data)
            } catch let decodingError as DecodingError {
                throw NetworkError.decodingError(statusCode: statusCode, error: decodingError)
            } catch {
                throw responseError(from: data, statusCode: statusCode)
            }
        default:
            throw responseError(from: data, statusCode: statusCode)
        }
    }

    /// The timeout a request is dispatched with: an endpoint's declared one or the default, and for any other resource
    /// its request's own timeout unless that is still URLRequest's built-in value.
    private static func timeoutInterval(for resource: URLRequestConvertible, preparedRequest: URLRequest) -> TimeInterval {
        if let endpoint = resource as? any Endpoint {
            return endpoint.timeoutInterval ?? defaultTimeoutInterval
        }
        // shortcut: a raw request left at URLRequest's built-in 60 s counts as setting no timeout, so one explicitly
        // set to 60 s gets the default too; declaring the timeout on an Endpoint is the exact form.
        return preparedRequest.timeoutInterval == builtInTimeoutInterval ? defaultTimeoutInterval : preparedRequest.timeoutInterval
    }

    // Shared helper — visible within the module so both the async and (legacy) callback paths use
    // the same error construction logic.
    static func responseError(from data: Data, statusCode: Int) -> NetworkError {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return .responseError(statusCode: statusCode, jsonObject: [:], responseAsData: data)
        }
        if shouldLog { Logger.log(["Response as jsonObject": jsonObject]) }
        return .responseError(statusCode: statusCode, jsonObject: jsonObject, responseAsData: data)
    }
}
