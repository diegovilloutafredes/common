//
//  HTTPService.swift
//

import Foundation

// MARK: - HTTPService

/// A service responsible for making HTTP requests.
public enum HTTPService {

    /// Performs an HTTP request and decodes the response to a specified type.
    ///
    /// Wraps the `async throws` overload in an unstructured `Task` for callback-based
    /// callers. The returned `URLSessionTask?` is always `nil` — cancellation is not
    /// supported through this API. Callers that need cancellation should use the
    /// async overload, which integrates with structured-concurrency cancellation.
    @discardableResult public static func request<T: Decodable>(
        _ resource: URLRequestConvertible,
        urlSession: URLSession = HTTPService.defaultSession,
        decoder: JSONDecoder = .init().keyDecodingStrategy(.convertFromSnakeCase),
        result: @escaping NetworkResultHandler<T>
    ) -> URLSessionTask? {
        Task {
            do {
                let value: T = try await request(resource, urlSession: urlSession, decoder: decoder)
                dispatchOnMain { result(.success(value)) }
            } catch let error as NetworkError {
                dispatchOnMain { result(.failure(error)) }
            } catch {
                dispatchOnMain { result(.failure(.requestError(error))) }
            }
        }
        return nil
    }

    /// Uploads a multipart request and decodes the response to a specified type.
    ///
    /// Wraps the `async throws` overload in an unstructured `Task` for callback-based
    /// callers. The returned `URLSessionTask?` is always `nil` — cancellation is not
    /// supported through this API. Callers that need cancellation should use the
    /// async overload.
    @discardableResult public static func upload<T: Decodable>(
        multipart: MultipartRequest,
        to resource: URLRequestConvertible,
        decoder: JSONDecoder = .init().keyDecodingStrategy(.convertFromSnakeCase),
        result: @escaping NetworkResultHandler<T>
    ) -> URLSessionTask? {
        Task {
            do {
                let value: T = try await upload(multipart: multipart, to: resource, decoder: decoder)
                dispatchOnMain { result(.success(value)) }
            } catch let error as NetworkError {
                dispatchOnMain { result(.failure(error)) }
            } catch {
                dispatchOnMain { result(.failure(.requestError(error))) }
            }
        }
        return nil
    }
}

// MARK: - Loggable
extension HTTPService: Loggable {}
