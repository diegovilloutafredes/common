//
//  HTTPService.swift
//

import Foundation

// MARK: - HTTPService

/// A service responsible for making HTTP requests.
public enum HTTPService {

    /// Performs an HTTP request and decodes the response to a specified type.
    ///
    /// - Deprecated: Use the `async throws` overload instead. This overload is a thin wrapper
    ///   over the async variant and no longer returns a cancellable `URLSessionTask`.
    @available(*, deprecated, message: "Use the async throws overload instead.")
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
    /// - Deprecated: Use the `async throws` overload instead.
    @available(*, deprecated, message: "Use the async throws overload instead.")
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
