//
//  NetworkError.swift
//

import Foundation

// MARK: - NetworkError
public enum NetworkError: Error, Stringable {
    case decodingError
    case requestError(Error)
    case responseError(code: Int, jsonObject: [String: Any], responseAsData: Data)
    case invalidRequest(URLRequestConvertible)
    case invalidURL(URLConvertible)
    case noDataReceived
    case parameterEncodingFailed

    public var asString: String {
        switch self {
        case .decodingError: "Response data could not be decoded"
        case .requestError(let message): "message: \(message)"
        case .responseError(let code, let jsonObject, let responseAsData): "code: \(code) jsonObject: \(jsonObject) responseAsData: \(responseAsData.asString() ?? .empty)"
        case .invalidRequest(let urlRequestConvertible): "\(urlRequestConvertible) is not a valid urlRequest"
        case .invalidURL(let url): "\(url) is not a valid url"
        case .noDataReceived: "No data received"
        case .parameterEncodingFailed: "Parameters could not be encoded"
        }
    }
}
