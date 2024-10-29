//
//  ClientProtocol.swift
//

import Foundation

// MARK: - ClientProtocol
public protocol ClientProtocol: AnyObject {
    var requests: [String: URLSessionTask] { get set }
    func request<T: Decodable>(from function: String, _ request: URLRequestConvertible, result: @escaping NetworkResultHandler<T>)
    func upload<T: Decodable>(from function: String, multipart: MultipartRequest, to request: URLRequestConvertible, result: @escaping NetworkResultHandler<T>)
}

// MARK: - Default Implementation
extension ClientProtocol {
    public func request<T: Decodable>(from function: String = #function, _ request: URLRequestConvertible, result: @escaping NetworkResultHandler<T>) {
        requests[function]?.cancel()
        requests[function] = HTTPService.request(request, result: result)
    }

    public func upload<T: Decodable>(from function: String = #function, multipart: MultipartRequest, to request: URLRequestConvertible, result: @escaping NetworkResultHandler<T>) {
        requests[function]?.cancel()
        requests[function] = HTTPService.upload(multipart: multipart, to: request, result: result)
    }
}
