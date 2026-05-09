//
//  HTTPHeaders.swift
//

import Foundation

public struct HTTPHeaders {
    private var headers: [HTTPHeader] = []

    public init() {}

    public init(_ headers: [HTTPHeader]) {
        self.init()
        headers.forEach { update($0) }
    }

    public init(_ dictionary: [String: String]) {
        self.init()
        dictionary.forEach { update(.init(name: $0.key, value: $0.value)) }
    }

    public mutating func add(name: String, value: String) {
        update(.init(name: name, value: value))
    }

    public mutating func add(_ header: HTTPHeader) {
        update(header)
    }

    public mutating func update(name: String, value: String) {
        update(.init(name: name, value: value))
    }

    public mutating func update(_ header: HTTPHeader) {
        guard let index = headers.index(of: header.name) else {
            headers.append(header)
            return
        }
        headers.replaceSubrange(index...index, with: [header])
    }

    public mutating func remove(name: String) {
        guard let index = headers.index(of: name) else { return }
        headers.remove(at: index)
    }

    public func value(for name: String) -> String? {
        guard let index = headers.index(of: name) else { return nil }
        return headers[index].value
    }

    public subscript(_ name: String) -> String? {
        get { value(for: name) }
        set {
            if let newValue { update(name: name, value: newValue) } else { remove(name: name) }
        }
    }

    public var dictionary: [String: String] {
        let namesAndValues = headers.map { ($0.name, $0.value) }
        return .init(namesAndValues, uniquingKeysWith: { _, last in last })
    }
}

extension HTTPHeaders: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, String)...) {
        self.init()
        elements.forEach { update(name: $0.0, value: $0.1) }
    }
}

extension HTTPHeaders: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: HTTPHeader...) {
        self.init(elements)
    }
}

extension HTTPHeaders: Sequence {
    public func makeIterator() -> IndexingIterator<[HTTPHeader]> {
        headers.makeIterator()
    }
}

extension HTTPHeaders: Collection {
    public var startIndex: Int { headers.startIndex }
    public var endIndex: Int { headers.endIndex }

    public subscript(position: Int) -> HTTPHeader { headers[position] }

    public func index(after i: Int) -> Int { headers.index(after: i) }
}

extension HTTPHeaders: CustomStringConvertible {
    public var description: String {
        headers.map(\.description).joined(separator: "\n")
    }
}

extension HTTPHeaders: ValueWithable {}

// MARK: - HTTPHeader

public struct HTTPHeader: Hashable {
    public let name: String
    public let value: String

    public init(name: String, value: String) {
        self.name = name
        self.value = value
    }
}

extension HTTPHeader: CustomStringConvertible {
    public var description: String { "\(name): \(value)" }
}

extension HTTPHeader {
    public static func accept(_ value: String) -> HTTPHeader {
        HTTPHeader(name: "Accept", value: value)
    }

    public static func acceptCharset(_ value: String) -> HTTPHeader {
        HTTPHeader(name: "Accept-Charset", value: value)
    }

    public static func acceptLanguage(_ value: String) -> HTTPHeader {
        HTTPHeader(name: "Accept-Language", value: value)
    }

    public static func acceptEncoding(_ value: String) -> HTTPHeader {
        HTTPHeader(name: "Accept-Encoding", value: value)
    }

    public static func authorization(username: String, password: String) -> HTTPHeader {
        let credential = Data("\(username):\(password)".utf8).base64EncodedString()
        return authorization("Basic \(credential)")
    }

    public static func authorization(bearerToken: String) -> HTTPHeader {
        authorization("Bearer \(bearerToken)")
    }

    public static func authorization(_ value: String) -> HTTPHeader {
        HTTPHeader(name: "Authorization", value: value)
    }

    public static func contentDisposition(_ value: String) -> HTTPHeader {
        HTTPHeader(name: "Content-Disposition", value: value)
    }

    public static func contentEncoding(_ value: String) -> HTTPHeader {
        HTTPHeader(name: "Content-Encoding", value: value)
    }

    public static func contentType(_ value: String) -> HTTPHeader {
        HTTPHeader(name: "Content-Type", value: value)
    }

    public static func userAgent(_ value: String) -> HTTPHeader {
        HTTPHeader(name: "User-Agent", value: value)
    }
}

extension Array where Element == HTTPHeader {
    func index(of name: String) -> Int? {
        let lowercasedName = name.lowercased()
        return firstIndex { $0.name.lowercased() == lowercasedName }
    }
}

// MARK: - System Type Extensions

extension URLRequest {
    public var headers: HTTPHeaders {
        get { allHTTPHeaderFields.map(HTTPHeaders.init) ?? HTTPHeaders() }
        set { allHTTPHeaderFields = newValue.dictionary }
    }
}

extension HTTPURLResponse {
    public var headers: HTTPHeaders {
        (allHeaderFields as? [String: String]).map(HTTPHeaders.init) ?? HTTPHeaders()
    }
}

extension URLSessionConfiguration {
    public var headers: HTTPHeaders {
        get { (httpAdditionalHeaders as? [String: String]).map(HTTPHeaders.init) ?? HTTPHeaders() }
        set { httpAdditionalHeaders = newValue.dictionary }
    }
}
