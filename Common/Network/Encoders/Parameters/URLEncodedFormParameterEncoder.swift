//
//  URLEncodedFormParameterEncoder.swift
//

import Foundation

public final class URLEncodedFormParameterEncoder: ParameterEncoder {
    public enum Destination {
        case methodDependent
        case queryString
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

    public init(encoder: URLEncodedFormEncoder = .init(), destination: Destination = .methodDependent) {
        self.encoder = encoder
        self.destination = destination
    }

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
