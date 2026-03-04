//
//  MultipartRequest.swift
//

import Foundation

// MARK: - MultipartRequest
// MARK: - MultipartRequest

/// A helper struct for creating multipart/form-data requests.
public struct MultipartRequest {
    private let boundary: String
    private let separator = "\r\n"
    private var data = Data()

    /// Initializes a new `MultipartRequest`.
    /// - Parameter boundary: The boundary string to use. Defaults to a random UUID string.
    public init(boundary: String = UUID().uuidString) {
        self.boundary = boundary
    }

    /// The Content-Type header value for the multipart request.
    public var contentTypeHeaderValue: String { "multipart/form-data; boundary=\(boundary)" }

    /// The HTTP body data for the request.
    public var httpBody: Data {
        var bodyData = data
        bodyData.append("--\(boundary)--")
        return bodyData
    }

    /// Adds a text field to the multipart request.
    ///
    /// - Parameters:
    ///   - key: The name of the field.
    ///   - value: The value of the field.
    public mutating func add(
        key: String,
        value: String
    ) {
        appendBoundarySeparator()
        data.append(disposition(key) + separator)
        appendSeparator()
        data.append(value + separator)
    }

    /// Adds a file to the multipart request.
    ///
    /// - Parameters:
    ///   - key: The name of the field.
    ///   - fileName: The name of the file.
    ///   - fileMimeType: The MIME type of the file.
    ///   - fileData: The data of the file.
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
