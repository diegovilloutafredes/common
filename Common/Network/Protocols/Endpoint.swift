//
//  Endpoint.swift
//

import Foundation

// MARK: - Endpoint
/// Defines a complete network endpoint with all necessary configuration.
public protocol Endpoint: URLRequestConvertible {
    
    /// The base URL for the endpoint.
    var baseURL: URL? { get }
    
    /// The API version.
    var version: String { get }
    
    /// The base path for the API.
    var basePath: String { get }
    
    /// The specific path for this endpoint.
    var path: String { get }
    
    /// The full URL for the request.
    var url: URL? { get }
    
    /// The HTTP headers to include.
    var headers: HTTPHeaders { get }
    
    /// The HTTP method to use (GET, POST, etc.).
    var method: HTTPMethod { get }
    
    /// The parameters to encode into the request.
    var parameters: Encodable? { get }
    
    /// The JSON encoder to use for parameters.
    var jsonEncoder: JSONEncoder { get }
    
    /// The URL encoded form encoder to use for parameters.
    var urlEncodedFormEncoder: URLEncodedFormEncoder { get }
}

// MARK: - Default Implementation
extension Endpoint {
    public var version: String { .empty }
    public var basePath: String { .empty }
    public var url: URL? { baseURL?.appendingPathComponent("\(basePath)\(version)\(path)") }
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

        return switch method {
        case .post: try JSONParameterEncoder(encoder: jsonEncoder).encode(parameters, into: urlRequest)
        default: try URLEncodedFormParameterEncoder(encoder: urlEncodedFormEncoder).encode(parameters, into: urlRequest)
        }
    }
}
