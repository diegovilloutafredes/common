//
//  ClientProtocol.swift
//

import Foundation

// MARK: - ClientProtocol
/// A protocol defining the contract for a network client capable of making requests.
public protocol ClientProtocol: AnyObject {
    
    /// A dictionary storing active network tasks, keyed by function or identifier.
    /// Tasks are `Task<Void, Never>` wrappers around the async network call;
    /// `cancel()` on the main actor aborts the in-flight request and prevents the result
    /// handler from firing, even when the response has already arrived.
    var requests: [String: Task<Void, Never>] { get set }
    
    /// Performs a network request and decodes the response.
    /// - Parameters:
    ///   - function: The identifier for the request, typically the calling function name.
    ///   - request: The request to perform.
    ///   - result: The completion handler for the result.
    func request<T: Decodable>(from function: String, _ request: URLRequestConvertible, result: @escaping NetworkResultHandler<T>)
    
    /// Performs a multipart upload request and decodes the response.
    /// - Parameters:
    ///   - function: The identifier for the request.
    ///   - multipart: The multipart data to upload.
    ///   - request: The base request.
    ///   - result: The completion handler for the result.
    func upload<T: Decodable>(from function: String, multipart: MultipartRequest, to request: URLRequestConvertible, result: @escaping NetworkResultHandler<T>)
}

// MARK: - Default Implementation
extension ClientProtocol {

    /// Performs a network request and decodes the response.
    public func request<T: Decodable>(from function: String = #function, _ request: URLRequestConvertible, result: @escaping NetworkResultHandler<T>) {
        self.request(
            from: function,
            request,
            urlSession: HTTPService.defaultSession,
            decoder: .init().keyDecodingStrategy(.convertFromSnakeCase),
            result: result
        )
    }

    /// Performs a multipart upload request and decodes the response.
    public func upload<T: Decodable>(from function: String = #function, multipart: MultipartRequest, to request: URLRequestConvertible, result: @escaping NetworkResultHandler<T>) {
        upload(
            from: function,
            multipart: multipart,
            to: request,
            urlSession: HTTPService.defaultSession,
            decoder: .init().keyDecodingStrategy(.convertFromSnakeCase),
            result: result
        )
    }

    /// Performs a network request through the given session and decodes the response with the given decoder.
    ///
    /// Like `request(from:_:result:)`, it cancels the previous in-flight request stored under the same `function`
    /// key. It sends the request itself, so a conformer's own implementation of `request(from:_:result:)` isn't
    /// involved.
    /// - Parameters:
    ///   - function: The identifier for the request, typically the calling function name.
    ///   - request: The request to perform.
    ///   - urlSession: The URLSession to use. Defaults to `HTTPService.defaultSession`.
    ///   - decoder: The JSONDecoder to use. Defaults to snake_case conversion.
    ///   - result: The completion handler for the result.
    public func request<T: Decodable>(
        from function: String = #function,
        _ request: URLRequestConvertible,
        urlSession: URLSession = HTTPService.defaultSession,
        decoder: JSONDecoder = .init().keyDecodingStrategy(.convertFromSnakeCase),
        result: @escaping NetworkResultHandler<T>
    ) {
        requests[function]?.cancel()
        requests[function] = HTTPService.request(request, urlSession: urlSession, decoder: decoder, result: result)
    }

    /// Performs a multipart upload through the given session and decodes the response with the given decoder.
    ///
    /// Like `upload(from:multipart:to:result:)`, it cancels the previous in-flight request stored under the same
    /// `function` key, and a conformer's own implementation of that method isn't involved.
    /// - Parameters:
    ///   - function: The identifier for the request.
    ///   - multipart: The multipart data to upload.
    ///   - request: The base request.
    ///   - urlSession: The URLSession to use. Defaults to `HTTPService.defaultSession`.
    ///   - decoder: The JSONDecoder to use. Defaults to snake_case conversion.
    ///   - result: The completion handler for the result.
    public func upload<T: Decodable>(
        from function: String = #function,
        multipart: MultipartRequest,
        to request: URLRequestConvertible,
        urlSession: URLSession = HTTPService.defaultSession,
        decoder: JSONDecoder = .init().keyDecodingStrategy(.convertFromSnakeCase),
        result: @escaping NetworkResultHandler<T>
    ) {
        requests[function]?.cancel()
        requests[function] = HTTPService.upload(multipart: multipart, to: request, urlSession: urlSession, decoder: decoder, result: result)
    }
}
