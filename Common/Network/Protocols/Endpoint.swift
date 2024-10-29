//
//  Endpoint.swift
//

import Foundation

// MARK: - Endpoint
public protocol Endpoint: URLRequestConvertible {
    var baseURL: URL? { get }
    var version: String { get }
    var servicePath: String { get }
    var path: String { get }
    var url: URL? { get }
    var headers: HTTPHeaders { get }
    var method: HTTPMethod { get }
    var parameters: Encodable? { get }
    var jsonEncoder: JSONEncoder { get }
    var urlEncodedFormEncoder: URLEncodedFormEncoder { get }
}

// MARK: - Default Implementation
extension Endpoint {
    public var version: String { .empty }
    public var servicePath: String { .empty }
    public var url: URL? { baseURL?.appendingPathComponent("\(servicePath)\(version)\(path)") }
    public var jsonEncoder: JSONEncoder { .init().keyEncodingStrategy(.convertToSnakeCase) }
    public var urlEncodedFormEncoder: URLEncodedFormEncoder { .init(keyEncoding: .convertToSnakeCase) }
}

// MARK: - URLRequestConvertible
extension Endpoint {
    public func asURLRequest() throws -> URLRequest {
        guard let url else { return .init(url: .init(string: .empty)!) }

        var urlRequest = URLRequest(url: url)

        defer {
            Logger.log(
                [
                    "Headers": String(describing: urlRequest.allHTTPHeaderFields ?? [:]),
                    "URL": urlRequest,
                    "Endpoint": "\(Self.self).\(self)",
                    "Parameters": parameters ?? [:]
                ]
            )
        }

        // MARK: - Headers
        urlRequest.headers = headers


        // MARK: - HTTPMethod
        urlRequest.httpMethod = method.rawValue


        // MARK: - Parameters Encoding
        guard let parameters else { return urlRequest }

        switch method {
        case .post: return try JSONParameterEncoder(encoder: jsonEncoder).encode(parameters, into: urlRequest)
        default: return try URLEncodedFormParameterEncoder(encoder: urlEncodedFormEncoder).encode(parameters, into: urlRequest)
        }
    }
}
