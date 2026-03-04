//
//  JSONParameterEncoder.swift
//

import Foundation

// MARK: - JSONParameterEncoder
// MARK: - JSONParameterEncoder
/// Encodes parameters into a `URLRequest` as JSON in the HTTP body.
public final class JSONParameterEncoder: ParameterEncoder {
	private let encoder: JSONEncoder

    /// Initializes the encoder with a specific underlying `JSONEncoder`.
    public init(encoder: JSONEncoder = .init()) {
		self.encoder = encoder
	}

    /// Encodes the parameters into the URLRequest.
    public func encode<T: Encodable>(_ parameters: T?, into request: URLRequest) throws -> URLRequest {
		guard let parameters else { return request }

		var request = request

		do {
			let data = try encoder.encode(parameters)
			request.httpBody = data
			guard request.allHTTPHeaderFields?["Content-Type"] == nil else { return request }
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		} catch {
            throw NetworkError.parameterEncodingFailed
		}

		return request
	}
}
