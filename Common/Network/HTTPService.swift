//
//  HTTPService.swift
//

import Foundation

// MARK: - HTTPService
public enum HTTPService {
    private static var urlSession: URLSession { .shared }

    @discardableResult public static func request<T: Decodable>(_ resource: URLRequestConvertible, decoder: JSONDecoder = .init().keyDecodingStrategy(.convertFromSnakeCase), queue: DispatchQueue = .global(qos: .userInitiated), result: @escaping NetworkResultHandler<T>) -> URLSessionTask? {
        guard let urlRequest = resource.urlRequest else {
            result(.failure(.invalidRequest(resource)))
            return nil
        }

        let dataTask = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            guard error.isNil else {
                Logger.log(["error": error!])
                dispatchOnMain { result(.failure(.requestError(error!))) }
                return
            }

            guard let data else {
                Logger.log(urlRequest, response: response)
                dispatchOnMain { result(.failure(.noDataReceived)) }
                return
            }

            Logger.log(urlRequest, data: data, response: response)

            guard let httpResponse = response as? HTTPURLResponse else { return }

            let statusCode = httpResponse.statusCode

            Logger.log(["statusCode": statusCode])

            do {
                switch statusCode {
                case 200...299:
                    let decodedResponse = try decoder.decode(T.self, from: data)
                    dispatchOnMain { result(.success(decodedResponse)) }
                default:
                    guard let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }
                    Logger.log(["response as jsonObject": jsonObject])
                    dispatchOnMain { result(.failure(.responseError(code: statusCode, response: jsonObject))) }
                }
            } catch { dispatchOnMain { result(.failure(.decodingError)) } }
        }

        queue.async { dataTask.resume() }

        return dataTask
    }

    @discardableResult public static func upload<T: Decodable>(multipart: MultipartRequest, to resource: URLRequestConvertible, decoder: JSONDecoder = .init().keyDecodingStrategy(.convertFromSnakeCase), queue: DispatchQueue = .global(qos: .userInitiated), result: @escaping NetworkResultHandler<T>) -> URLSessionTask? {
        guard var urlRequest = resource.urlRequest else {
            result(.failure(.invalidRequest(resource)))
            return nil
        }

        Logger.log(["multipart": multipart])

        let contentType = multipart.contentTypeHeaderValue
        urlRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = multipart.httpBody

        return request(urlRequest, decoder: decoder, queue: queue, result: result)
    }
}
