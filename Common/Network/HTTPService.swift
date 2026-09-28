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
    /// callers. The returned `Task` can be cancelled to abort the in-flight request;
    /// cancellation propagates to the underlying `URLSession.data(for:)` and the
    /// result handler is not invoked. Cancellation is checked on the main actor at the
    /// moment of delivery, so a `Task` cancelled on the main actor before its handler
    /// runs never delivers. Callers already in Swift Concurrency should prefer the
    /// async overload directly.
    @discardableResult public static func request<T: Decodable>(
        _ resource: URLRequestConvertible,
        urlSession: URLSession = HTTPService.defaultSession,
        decoder: JSONDecoder = .init().keyDecodingStrategy(.convertFromSnakeCase),
        result: @escaping NetworkResultHandler<T>
    ) -> Task<Void, Never> {
        Task {
            let outcome: Result<T, NetworkError>
            do {
                let value: T = try await request(resource, urlSession: urlSession, decoder: decoder)
                outcome = .success(value)
            } catch let error as NetworkError {
                outcome = .failure(error)
            } catch {
                outcome = .failure(.requestError(error))
            }
            // Checked on the main actor, in the same step as the delivery: a cancel issued on the main actor either
            // lands first and is seen here, or after the handler has run.
            await MainActor.run {
                guard !Task.isCancelled else { return }
                result(outcome)
            }
        }
    }

    /// Uploads a multipart request and decodes the response to a specified type.
    ///
    /// Wraps the `async throws` overload in an unstructured `Task` for callback-based
    /// callers. The returned `Task` can be cancelled to abort the in-flight upload;
    /// cancellation propagates to the underlying `URLSession.data(for:)` and the
    /// result handler is not invoked. Cancellation is checked on the main actor at the
    /// moment of delivery, so a `Task` cancelled on the main actor before its handler
    /// runs never delivers.
    @discardableResult public static func upload<T: Decodable>(
        multipart: MultipartRequest,
        to resource: URLRequestConvertible,
        decoder: JSONDecoder = .init().keyDecodingStrategy(.convertFromSnakeCase),
        result: @escaping NetworkResultHandler<T>
    ) -> Task<Void, Never> {
        Task {
            let outcome: Result<T, NetworkError>
            do {
                let value: T = try await upload(multipart: multipart, to: resource, decoder: decoder)
                outcome = .success(value)
            } catch let error as NetworkError {
                outcome = .failure(error)
            } catch {
                outcome = .failure(.requestError(error))
            }
            // Checked on the main actor, in the same step as the delivery: a cancel issued on the main actor either
            // lands first and is seen here, or after the handler has run.
            await MainActor.run {
                guard !Task.isCancelled else { return }
                result(outcome)
            }
        }
    }
}

// MARK: - Loggable
extension HTTPService: Loggable {}
