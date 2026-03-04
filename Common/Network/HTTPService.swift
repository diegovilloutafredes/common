//
//  HTTPService.swift
//

import Foundation

// MARK: - HTTPService
// MARK: - HTTPService

/// A service responsible for making HTTP requests.
public enum HTTPService {
    
    /// Performs an HTTP request and decodes the response to a specified type.
    ///
    /// - Parameters:
    ///   - resource: The resource to request (e.g., a URL or URLRequest).
    ///   - urlSession: The URLSession to use for the request. Defaults to `.shared`.
    ///   - decoder: The JSONDecoder to use for decoding the response. Defaults to a strategy converting from snake_case.
    ///   - result: A closure to handle the result of the request.
    /// - Returns: The created `URLSessionTask`, or `nil` if the request could not be created.
    @discardableResult public static func request<T: Decodable>(_ resource: URLRequestConvertible, urlSession: URLSession = .shared, decoder: JSONDecoder = .init().keyDecodingStrategy(.convertFromSnakeCase), result: @escaping NetworkResultHandler<T>) -> URLSessionTask? {
        guard let urlRequest = resource.urlRequest else { result(.failure(.invalidRequest(resource))); return nil }

        let dataTask = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            if
                shouldLog,
                let beforeRequestTime: Int64 = store.get(using: "beforeRequestTime")
            {
                let afterRequestTime = Date.asMilliseconds
                let delta = afterRequestTime - beforeRequestTime
                Logger.log(["Request delta of \(resource.urlRequest!)": "\(delta)ms"])
            }

            guard error.isNil else {
                if shouldLog { Logger.log(["error": error!]) }
                dispatchOnMain { result(.failure(.requestError(error!))) }
                return
            }

            guard let data else {
                if shouldLog { Logger.log(urlRequest, response: response) }
                dispatchOnMain { result(.failure(.noDataReceived)) }
                return
            }

            if shouldLog { Logger.log(urlRequest, data: data, response: response) }

            guard let httpResponse = response as? HTTPURLResponse else { return }

            let statusCode = httpResponse.statusCode

            switch statusCode {
            case 200...299:
                do {
                    let decodedResponse = try decoder.decode(T.self, from: data)
                    dispatchOnMain { result(.success(decodedResponse)) }
                } catch {
                    guard let error = error as? DecodingError else {
                        defaultResponseHandling(data: data, statusCode: statusCode, result: result)
                        return
                    }
                    dispatchOnMain { result(.failure(.decodingError(statusCode: statusCode, error: error))) }
                }
            default: defaultResponseHandling(data: data, statusCode: statusCode, result: result)
            }
        }

        store.remove(using: "beforeRequestTime")
        let beforeRequestTime = Date.asMilliseconds
        store.add(item: ("beforeRequestTime", beforeRequestTime))
        dataTask.resume()

        return dataTask
    }

    /// Uploads a multipart request and decodes the response to a specified type.
    ///
    /// - Parameters:
    ///   - multipart: The multipart data to upload.
    ///   - resource: The resource to upload to (e.g., a URL or URLRequest).
    ///   - decoder: The JSONDecoder to use for decoding the response. Defaults to a strategy converting from snake_case.
    ///   - result: A closure to handle the result of the request.
    /// - Returns: The created `URLSessionTask`, or `nil` if the request could not be created.
    @discardableResult public static func upload<T: Decodable>(multipart: MultipartRequest, to resource: URLRequestConvertible, decoder: JSONDecoder = .init().keyDecodingStrategy(.convertFromSnakeCase), result: @escaping NetworkResultHandler<T>) -> URLSessionTask? {
        guard var urlRequest = resource.urlRequest else { result(.failure(.invalidRequest(resource))); return nil }

        if shouldLog { Logger.log(["multipart": multipart]) }

        let contentType = multipart.contentTypeHeaderValue
        urlRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = multipart.httpBody

        return request(urlRequest, decoder: decoder, result: result)
    }
}

extension HTTPService {
    private static func defaultResponseHandling<T: Decodable>(data: Data, statusCode: Int, result: @escaping NetworkResultHandler<T>) {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            dispatchOnMain { result(.failure(.responseError(statusCode: statusCode, jsonObject: [:], responseAsData: data))) }
            return
        }

        if shouldLog { Logger.log(["Response as jsonObject": jsonObject]) }

        dispatchOnMain { result(.failure(.responseError(statusCode: statusCode, jsonObject: jsonObject, responseAsData: data))) }
    }
}

// MARK: - KeyValueStore
extension HTTPService {
    private static var store: KeyValueStore { .init() }
}

// MARK: - Loggable
extension HTTPService: Loggable {}
