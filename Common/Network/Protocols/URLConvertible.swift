//
//  URLConvertible.swift
//

import Foundation

// MARK: - URLConvertible
// MARK: - URLConvertible
/// A type that can be converted into a `URL`.
public protocol URLConvertible {
    
    /// Returns a `URL` representation or throws an error.
    func asURL() throws -> URL
}

extension String: URLConvertible {
    public func asURL() throws -> URL {
        guard let url = URL(string: self) else { throw NetworkError.invalidURL(self) }
        return url
    }
}

extension URL: URLConvertible {
    public func asURL() throws -> URL { self }
}

extension URLComponents: URLConvertible {
    public func asURL() throws -> URL {
        guard let url else { throw NetworkError.invalidURL(self) }
        return url
    }
}
