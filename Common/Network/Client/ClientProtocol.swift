//
//  ClientProtocol.swift
//

import Foundation

// MARK: - ClientProtocol
// MARK: - ClientProtocol
/// A protocol defining the contract for a network client capable of making requests.
public protocol ClientProtocol: AnyObject {
    
    /// A dictionary storing active network tasks, keyed by function or identifier.
    var requests: [String: URLSessionTask] { get set }
    
    /// Performs a network request and decodes the response.
    /// - Parameters:
    ///   - function: The identifier for the request, typically the calling function name.
    ///   - request: The request to perform.
    ///   - result: The completion handler for the result.
    func request<T: Decodable>(from function: String, _ request: URLRequestConvertible, result: @escaping NetworkResultHandler<T>)
    
    /// Performs a multipart upload request and decodes the response.
    /// - Parameters:
    ///   - function: The identifier for the request.
    ///   - multipart: The multipart data to upload.
    ///   - request: The base request.
    ///   - result: The completion handler for the result.
    func upload<T: Decodable>(from function: String, multipart: MultipartRequest, to request: URLRequestConvertible, result: @escaping NetworkResultHandler<T>)
}

// MARK: - Default Implementation
extension ClientProtocol {
    
    /// Performs a network request and decodes the response.
    public func request<T: Decodable>(from function: String = #function, _ request: URLRequestConvertible, result: @escaping NetworkResultHandler<T>) {
        requests[function]?.cancel()
        requests[function] = HTTPService.request(request, result: result)
    }

    /// Performs a multipart upload request and decodes the response.
    public func upload<T: Decodable>(from function: String = #function, multipart: MultipartRequest, to request: URLRequestConvertible, result: @escaping NetworkResultHandler<T>) {
        requests[function]?.cancel()
        requests[function] = HTTPService.upload(multipart: multipart, to: request, result: result)
    }
}
