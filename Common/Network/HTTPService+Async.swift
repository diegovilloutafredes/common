//
//  HTTPService+Async.swift
//

import Foundation

// MARK: - HTTPService (Async)
extension HTTPService {

    /// URLSession used for all requests. Override in tests via `HTTPService.defaultSession = mockSession`.
    public static var defaultSession: URLSession = .shared

    /// Timeout applied to every outbound `URLRequest`. Defaults to 60 s (same as URLRequest's built-in default).
    public static var defaultTimeoutInterval: TimeInterval = 60

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
        guard let urlRequest = resource.urlRequest else {
            throw NetworkError.invalidRequest(resource)
        }

        var mutableRequest = urlRequest
        mutableRequest.timeoutInterval = HTTPService.defaultTimeoutInterval

        let beforeRequestTime = Date.asMilliseconds
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await urlSession.data(for: mutableRequest)
        } catch is CancellationError {
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
        guard var urlRequest = resource.urlRequest else {
            throw NetworkError.invalidRequest(resource)
        }

        if shouldLog { Logger.log(["multipart": multipart]) }

        urlRequest.setValue(multipart.contentTypeHeaderValue, forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = multipart.httpBody

        return try await request(urlRequest, decoder: decoder)
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
