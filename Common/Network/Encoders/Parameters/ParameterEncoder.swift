//
//  ParameterEncoder.swift
//

import Foundation

// MARK: - ParameterEncoder
protocol ParameterEncoder {
    func encode<Parameters: Encodable>(_ parameters: Parameters?, into: URLRequest) throws -> URLRequest
}

extension ParameterEncoder where Self == JSONParameterEncoder {
    static var json: JSONParameterEncoder { .init() }
    static func json(encoder: JSONEncoder = JSONEncoder()) -> JSONParameterEncoder { .init(encoder: encoder) }
}

extension ParameterEncoder where Self == URLEncodedFormParameterEncoder {
    static var urlEncodedForm: URLEncodedFormParameterEncoder { .init() }
    static func urlEncodedForm(encoder: URLEncodedFormEncoder = URLEncodedFormEncoder(), destination: URLEncodedFormParameterEncoder.Destination = .methodDependent) -> URLEncodedFormParameterEncoder { .init(encoder: encoder, destination: destination) }
}
