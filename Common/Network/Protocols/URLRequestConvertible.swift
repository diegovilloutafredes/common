//
//  URLRequestConvertible.swift
//

import Foundation

// MARK: - URLRequestConvertible
/// A type that can be converted into a `URLRequest`.
public protocol URLRequestConvertible {
    
    /// Returns a `URLRequest` representation or throws an error.
    func asURLRequest() throws -> URLRequest
}

extension URLRequestConvertible {
    public var urlRequest: URLRequest? { try? asURLRequest() }
}

extension URLRequest: URLRequestConvertible {
    public func asURLRequest() throws -> URLRequest { self }
}

extension URLRequest {
    public init(url: URLConvertible, method: HTTPMethod, headers: HTTPHeaders? = nil) throws {
        let url = try url.asURL()
        self.init(url: url)
        httpMethod = method.rawValue
        allHTTPHeaderFields = headers?.dictionary
    }
}
