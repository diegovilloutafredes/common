//
//  ParameterEncoder.swift
//

import Foundation

// MARK: - ParameterEncoder
/// A type that encodes parameters into a `URLRequest`.
public protocol ParameterEncoder {
    
    /// Encodes the given parameters into the request.
    /// - Parameters:
    ///   - parameters: The parameters to encode.
    ///   - request: The request to encode parameters into.
    /// - Returns: The URLRequest with encoded parameters.
    func encode<Parameters: Encodable>(_ parameters: Parameters?, into: URLRequest) throws -> URLRequest
}

extension ParameterEncoder where Self == JSONParameterEncoder {
    
    /// Creates a JSON parameter encoder.
    public static var json: JSONParameterEncoder { .init() }

    /// Creates a JSON parameter encoder with a specific underlying `JSONEncoder`.
    public static func json(encoder: JSONEncoder = JSONEncoder()) -> JSONParameterEncoder { .init(encoder: encoder) }
}

extension ParameterEncoder where Self == URLEncodedFormParameterEncoder {
    
    /// Creates a URL encoded form parameter encoder.
    public static var urlEncodedForm: URLEncodedFormParameterEncoder { .init() }

    /// Creates a URL encoded form parameter encoder with specific configuration.
    public static func urlEncodedForm(encoder: URLEncodedFormEncoder = URLEncodedFormEncoder(), destination: URLEncodedFormParameterEncoder.Destination = .methodDependent) -> URLEncodedFormParameterEncoder { .init(encoder: encoder, destination: destination) }
}
