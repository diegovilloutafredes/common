//
//  AsyncClientProtocol.swift
//

import Foundation

// MARK: - AsyncClientProtocol
/// A protocol defining the contract for a network client that uses async/await.
///
/// Unlike `ClientProtocol`, this protocol does not track in-flight tasks.
/// Callers own the request lifecycle via Swift's structured concurrency
/// (e.g., `.task {}` in SwiftUI cancels automatically on view disappear).
public protocol AsyncClientProtocol: AnyObject {}

// MARK: - Default Implementation
extension AsyncClientProtocol {

    /// Performs a network request asynchronously and decodes the response.
    /// - Parameters:
    ///   - function: The identifier for the request (unused for lifecycle management; kept for API symmetry with `ClientProtocol`).
    ///   - request: The request to perform.
    /// - Returns: The decoded response of type `T`.
    /// - Throws: `NetworkError` on failure, or `CancellationError` if the enclosing Task is cancelled.
    public func request<T: Decodable>(
        from function: String = #function,
        _ request: URLRequestConvertible
    ) async throws -> T {
        try await self.request(
            from: function,
            request,
            urlSession: HTTPService.defaultSession,
            decoder: .init().keyDecodingStrategy(.convertFromSnakeCase)
        )
    }

    /// Performs a multipart upload request asynchronously and decodes the response.
    /// - Parameters:
    ///   - function: The identifier for the request.
    ///   - multipart: The multipart data to upload.
    ///   - request: The base request.
    /// - Returns: The decoded response of type `T`.
    /// - Throws: `NetworkError` on failure, or `CancellationError` if the enclosing Task is cancelled.
    public func upload<T: Decodable>(
        from function: String = #function,
        multipart: MultipartRequest,
        to request: URLRequestConvertible
    ) async throws -> T {
        try await upload(
            from: function,
            multipart: multipart,
            to: request,
            urlSession: HTTPService.defaultSession,
            decoder: .init().keyDecodingStrategy(.convertFromSnakeCase)
        )
    }

    /// Performs a network request asynchronously through the given session and decodes the response with the given
    /// decoder.
    /// - Parameters:
    ///   - function: The identifier for the request (unused for lifecycle management; kept for API symmetry with `ClientProtocol`).
    ///   - request: The request to perform.
    ///   - urlSession: The URLSession to use. Defaults to `HTTPService.defaultSession`.
    ///   - decoder: The JSONDecoder to use. Defaults to snake_case conversion.
    /// - Returns: The decoded response of type `T`.
    /// - Throws: `NetworkError` on failure, or `CancellationError` if the enclosing Task is cancelled.
    public func request<T: Decodable>(
        from function: String = #function,
        _ request: URLRequestConvertible,
        urlSession: URLSession = HTTPService.defaultSession,
        decoder: JSONDecoder = .init().keyDecodingStrategy(.convertFromSnakeCase)
    ) async throws -> T {
        try await HTTPService.request(request, urlSession: urlSession, decoder: decoder)
    }

    /// Performs a multipart upload asynchronously through the given session and decodes the response with the given
    /// decoder.
    /// - Parameters:
    ///   - function: The identifier for the request.
    ///   - multipart: The multipart data to upload.
    ///   - request: The base request.
    ///   - urlSession: The URLSession to use. Defaults to `HTTPService.defaultSession`.
    ///   - decoder: The JSONDecoder to use. Defaults to snake_case conversion.
    /// - Returns: The decoded response of type `T`.
    /// - Throws: `NetworkError` on failure, or `CancellationError` if the enclosing Task is cancelled.
    public func upload<T: Decodable>(
        from function: String = #function,
        multipart: MultipartRequest,
        to request: URLRequestConvertible,
        urlSession: URLSession = HTTPService.defaultSession,
        decoder: JSONDecoder = .init().keyDecodingStrategy(.convertFromSnakeCase)
    ) async throws -> T {
        try await HTTPService.upload(multipart: multipart, to: request, urlSession: urlSession, decoder: decoder)
    }
}
