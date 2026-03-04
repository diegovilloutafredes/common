//
//  URLEncodedFormParameterEncoder.swift
//

import Foundation

/// Encodes parameters into a `URLRequest` using URL-encoded form encoding.
public final class URLEncodedFormParameterEncoder: ParameterEncoder {
    
    /// Defines where the parameters should be encoded.
    public enum Destination {
        
        /// Applies parameters to the URL query string or HTTP body based on the HTTP method.
        case methodDependent
        
        /// Always applies parameters to the URL query string.
        case queryString
        
        /// Always applies parameters to the HTTP body.
        case httpBody

        func encodesParametersInURL(for method: HTTPMethod) -> Bool {
            switch self {
            case .methodDependent: [.get, .head, .delete].contains(method)
            case .queryString: true
            case .httpBody: false
            }
        }
    }

    let encoder: URLEncodedFormEncoder
    let destination: Destination

    /// Initializes the encoder with a specific underlying encoder and destination.
    public init(encoder: URLEncodedFormEncoder = .init(), destination: Destination = .methodDependent) {
        self.encoder = encoder
        self.destination = destination
    }

    /// Encodes the parameters into the URLRequest.
    public func encode<Parameters: Encodable>(_ parameters: Parameters?, into request: URLRequest) throws -> URLRequest {
        guard let parameters else { return request }

        var request = request

        guard let url = request.url else {
            throw NetworkError.parameterEncodingFailed
        }

        guard let method = request.method else {
            throw NetworkError.parameterEncodingFailed
        }

        if destination.encodesParametersInURL(for: method),
           var components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            let query: String = try Result<String, Error> { try encoder.encode(parameters) }.mapError { $0 }.get()
            let newQueryString = [components.percentEncodedQuery, query].compactMap { $0 }.joinedWithAmpersands()
            components.percentEncodedQuery = newQueryString.isEmpty ? nil : newQueryString

            guard let newURL = components.url else {
                throw NetworkError.parameterEncodingFailed
            }

            request.url = newURL
        } else {
            if request.headers["Content-Type"] == nil {
                request.headers.update(.contentType("application/x-www-form-urlencoded; charset=utf-8"))
            }

            request.httpBody = try Result<Data, Error> { try encoder.encode(parameters) }.mapError { $0 }.get()
        }

        return request
    }
}

extension URLRequest {
    var method: HTTPMethod? {
        get { httpMethod.map(HTTPMethod.init) }
        set { httpMethod = newValue?.rawValue }
    }
}
