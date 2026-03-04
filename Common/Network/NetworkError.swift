//
//  NetworkError.swift
//

import Foundation

// MARK: - NetworkError
// MARK: - NetworkError

/// Represents errors that can occur during network operations.
public enum NetworkError: Error, Stringable {
    
    /// A custom error with a specific message.
    case custom(message: String)
    
    /// An error occurred while decoding the response.
    case decodingError(statusCode: Int, error: DecodingError)
    
    /// An error occurred with the request itself (e.g., connectivity issues).
    case requestError(Error)
    
    /// The server returned an error response.
    case responseError(statusCode: Int, jsonObject: [String: Any], responseAsData: Data)
    
    /// The request object could not be created or is invalid.
    case invalidRequest(URLRequestConvertible)
    
    /// The URL string is invalid.
    case invalidURL(URLConvertible)
    
    /// No data was received from the server.
    case noDataReceived
    
    /// Parameters could not be encoded into the request.
    case parameterEncodingFailed

    /// A string representation of the error.
    public var asString: String {
        switch self {
        case .custom(let message): "message: \(message)"
        case .decodingError(let statusCode, let error): "Status Code: \(statusCode): Response data could not be decoded. Error \(error)"
        case .requestError(let error): "error: \(error)"
        case .responseError(let statusCode, let jsonObject, let responseAsData): "Status Code: \(statusCode) jsonObject: \(jsonObject) responseAsData: \(responseAsData.asString() ?? .empty)"
        case .invalidRequest(let urlRequestConvertible): "\(urlRequestConvertible) is not a valid URLRequest"
        case .invalidURL(let urlConvertible): "\(urlConvertible) is not a valid URL"
        case .noDataReceived: "No data received"
        case .parameterEncodingFailed: "Parameters could not be encoded"
        }
    }
}
