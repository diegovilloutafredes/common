//
//  MultipartRequest.swift
//

import Foundation

// MARK: - MultipartRequest
public struct MultipartRequest {
    private let boundary: String
    private let separator = "\r\n"
    private var data = Data()

    public init(boundary: String = UUID().uuidString) {
        self.boundary = boundary
    }

    public var contentTypeHeaderValue: String { "multipart/form-data; boundary=\(boundary)" }

    public var httpBody: Data {
        var bodyData = data
        bodyData.append("--\(boundary)--")
        return bodyData
    }

    public mutating func add(
        key: String,
        value: String
    ) {
        appendBoundarySeparator()
        data.append(disposition(key) + separator)
        appendSeparator()
        data.append(value + separator)
    }

    public mutating func add(
        key: String,
        fileName: String,
        fileMimeType: String,
        fileData: Data
    ) {
        appendBoundarySeparator()
        data.append(disposition(key) + "; filename=\"\(fileName)\"" + separator)
        data.append("Content-Type: \(fileMimeType)" + separator + separator)
        data.append(fileData)
        appendSeparator()
    }

    private mutating func appendBoundarySeparator() { data.append("--\(boundary)\(separator)") }
    private mutating func appendSeparator() { data.append(separator) }
    private func disposition(_ key: String) -> String { "Content-Disposition: form-data; name=\"\(key)\"" }
}

// MARK: - ValueWithable
extension MultipartRequest: ValueWithable {}
