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
        deliver(to: result) { try await request(resource, urlSession: urlSession, decoder: decoder) }
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
        upload(multipart: multipart, to: resource, urlSession: HTTPService.defaultSession, decoder: decoder, result: result)
    }

    /// Uploads a multipart request through the given session and decodes the response to a specified type.
    ///
    /// Wraps the `async throws` overload in an unstructured `Task` for callback-based
    /// callers, with the same cancellation contract as the overload without a session.
    @discardableResult public static func upload<T: Decodable>(
        multipart: MultipartRequest,
        to resource: URLRequestConvertible,
        urlSession: URLSession = HTTPService.defaultSession,
        decoder: JSONDecoder = .init().keyDecodingStrategy(.convertFromSnakeCase),
        result: @escaping NetworkResultHandler<T>
    ) -> Task<Void, Never> {
        deliver(to: result) { try await upload(multipart: multipart, to: resource, urlSession: urlSession, decoder: decoder) }
    }

    /// The callback bridge: runs `operation` in an unstructured `Task` and hands its outcome to `result` on the main
    /// actor, unless the task was cancelled by then.
    private static func deliver<T>(
        to result: @escaping NetworkResultHandler<T>,
        from operation: @escaping () async throws -> T
    ) -> Task<Void, Never> {
        Task {
            let outcome: Result<T, NetworkError>
            do {
                outcome = .success(try await operation())
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
