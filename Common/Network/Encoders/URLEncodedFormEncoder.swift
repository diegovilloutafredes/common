//
//  URLEncodedFormEncoder.swift
//

import Foundation

public final class URLEncodedFormEncoder {
    public enum KeyEncoding {
        case useDefaultKeys
        case convertToSnakeCase
        case convertToKebabCase
        case capitalized
        case uppercased
        case lowercased
        case custom((String) -> String)

        func encode(_ key: String) -> String {
            switch self {
            case .useDefaultKeys: return key
            case .convertToSnakeCase: return convert(key, separator: "_")
            case .convertToKebabCase: return convert(key, separator: "-")
            case .capitalized: return String(key.prefix(1).uppercased() + key.dropFirst())
            case .uppercased: return key.uppercased()
            case .lowercased: return key.lowercased()
            case let .custom(encoding): return encoding(key)
            }
        }

        private func convert(_ key: String, separator: String) -> String {
            guard !key.isEmpty else { return key }
            var words: [Range<String.Index>] = []
            var wordStart = key.startIndex
            var searchRange = key.index(after: wordStart)..<key.endIndex
            while let upper = key.rangeOfCharacter(from: .uppercaseLetters, options: [], range: searchRange) {
                words.append(wordStart..<upper.lowerBound)
                searchRange = upper.lowerBound..<searchRange.upperBound
                guard let lower = key.rangeOfCharacter(from: .lowercaseLetters, options: [], range: searchRange) else {
                    wordStart = searchRange.lowerBound
                    break
                }
                let next = key.index(after: upper.lowerBound)
                if lower.lowerBound == next {
                    wordStart = upper.lowerBound
                } else {
                    let beforeLower = key.index(before: lower.lowerBound)
                    words.append(upper.lowerBound..<beforeLower)
                    wordStart = beforeLower
                }
                searchRange = lower.upperBound..<searchRange.upperBound
            }
            words.append(wordStart..<searchRange.upperBound)
            return words.map { key[$0].lowercased() }.joined(separator: separator)
        }
    }

    let keyEncoding: KeyEncoding

    public init(keyEncoding: KeyEncoding = .useDefaultKeys) {
        self.keyEncoding = keyEncoding
    }

    func encode(_ value: Encodable) throws -> String {
        let context = URLEncodedFormContext(.object([]))
        try value.encode(to: _URLEncodedFormEncoder(context: context))
        guard case let .object(object) = context.component else {
            throw EncodingError.invalidValue(
                value,
                .init(codingPath: [], debugDescription: "URLEncodedFormEncoder requires a keyed root object.")
            )
        }
        return URLEncodedFormSerializer(keyEncoding: keyEncoding).serialize(object)
    }

    func encode(_ value: Encodable) throws -> Data {
        let string: String = try encode(value)
        return Data(string.utf8)
    }
}

// MARK: - Internal encoder

final class _URLEncodedFormEncoder {
    var codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey: Any] { [:] }
    let context: URLEncodedFormContext

    init(context: URLEncodedFormContext, codingPath: [CodingKey] = []) {
        self.context = context
        self.codingPath = codingPath
    }
}

extension _URLEncodedFormEncoder: Encoder {
    func container<Key: CodingKey>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
        KeyedEncodingContainer(_URLEncodedFormEncoder.KeyedContainer<Key>(context: context, codingPath: codingPath))
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        _URLEncodedFormEncoder.UnkeyedContainer(context: context, codingPath: codingPath)
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        _URLEncodedFormEncoder.SingleValueContainer(context: context, codingPath: codingPath)
    }
}

// MARK: - Context & Component

final class URLEncodedFormContext {
    var component: URLEncodedFormComponent

    init(_ component: URLEncodedFormComponent) {
        self.component = component
    }
}

enum URLEncodedFormComponent {
    typealias Object = [(key: String, value: URLEncodedFormComponent)]

    case string(String)
    case array([URLEncodedFormComponent])
    case object(Object)

    mutating func set(to value: URLEncodedFormComponent, at path: [CodingKey]) {
        set(&self, to: value, at: path)
    }

    private func set(_ context: inout URLEncodedFormComponent, to value: URLEncodedFormComponent, at path: [CodingKey]) {
        guard !path.isEmpty else { context = value; return }
        let end = path[0]
        var child: URLEncodedFormComponent
        switch path.count {
        case 1:
            child = value
        case 2...:
            if let index = end.intValue {
                let array = context.array ?? []
                child = array.count > index ? array[index] : .array([])
                set(&child, to: value, at: Array(path[1...]))
            } else {
                child = context.object?.first { $0.key == end.stringValue }?.value ?? .object([])
                set(&child, to: value, at: Array(path[1...]))
            }
        default: fatalError("Unreachable")
        }

        if let index = end.intValue {
            if var array = context.array {
                if array.count > index { array[index] = child } else { array.append(child) }
                context = .array(array)
            } else {
                context = .array([child])
            }
        } else {
            if var object = context.object {
                if let idx = object.firstIndex(where: { $0.key == end.stringValue }) {
                    object[idx] = (key: end.stringValue, value: child)
                } else {
                    object.append((key: end.stringValue, value: child))
                }
                context = .object(object)
            } else {
                context = .object([(key: end.stringValue, value: child)])
            }
        }
    }

    var array: [URLEncodedFormComponent]? {
        if case let .array(a) = self { return a }; return nil
    }

    var object: Object? {
        if case let .object(o) = self { return o }; return nil
    }
}

struct AnyCodingKey: CodingKey, Hashable {
    let stringValue: String
    let intValue: Int?

    init?(stringValue: String) { self.stringValue = stringValue; intValue = nil }
    init?(intValue: Int) { stringValue = "\(intValue)"; self.intValue = intValue }
    init<Key: CodingKey>(_ base: Key) {
        if let i = base.intValue { self.init(intValue: i)! } else { self.init(stringValue: base.stringValue)! }
    }
}

// MARK: - Keyed container

extension _URLEncodedFormEncoder {
    final class KeyedContainer<Key: CodingKey> {
        var codingPath: [CodingKey]
        private let context: URLEncodedFormContext

        init(context: URLEncodedFormContext, codingPath: [CodingKey]) {
            self.context = context
            self.codingPath = codingPath
        }
    }
}

extension _URLEncodedFormEncoder.KeyedContainer: KeyedEncodingContainerProtocol {
    func encodeNil(forKey key: Key) throws {}

    func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
        var container = nestedSingleValueEncoder(for: key)
        try container.encode(value)
    }

    func nestedSingleValueEncoder(for key: Key) -> SingleValueEncodingContainer {
        _URLEncodedFormEncoder.SingleValueContainer(context: context, codingPath: codingPath + [key])
    }

    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        _URLEncodedFormEncoder.UnkeyedContainer(context: context, codingPath: codingPath + [key])
    }

    func nestedContainer<NK: CodingKey>(keyedBy keyType: NK.Type, forKey key: Key) -> KeyedEncodingContainer<NK> {
        KeyedEncodingContainer(_URLEncodedFormEncoder.KeyedContainer<NK>(context: context, codingPath: codingPath + [key]))
    }

    func superEncoder() -> Encoder { _URLEncodedFormEncoder(context: context, codingPath: codingPath) }
    func superEncoder(forKey key: Key) -> Encoder { _URLEncodedFormEncoder(context: context, codingPath: codingPath + [key]) }
}

// MARK: - Single value container

extension _URLEncodedFormEncoder {
    final class SingleValueContainer {
        var codingPath: [CodingKey]
        private var canEncodeNewValue = true
        private let context: URLEncodedFormContext

        init(context: URLEncodedFormContext, codingPath: [CodingKey]) {
            self.context = context
            self.codingPath = codingPath
        }
    }
}

extension _URLEncodedFormEncoder.SingleValueContainer: SingleValueEncodingContainer {
    func encodeNil() throws {}
    func encode(_ value: Bool) throws   { try set(value, as: value ? "1" : "0") }
    func encode(_ value: String) throws { try set(value, as: value) }
    func encode(_ value: Double) throws { try set(value, as: String(value)) }
    func encode(_ value: Float) throws  { try set(value, as: String(value)) }
    func encode(_ value: Int) throws    { try set(value, as: String(value)) }
    func encode(_ value: Int8) throws   { try set(value, as: String(value)) }
    func encode(_ value: Int16) throws  { try set(value, as: String(value)) }
    func encode(_ value: Int32) throws  { try set(value, as: String(value)) }
    func encode(_ value: Int64) throws  { try set(value, as: String(value)) }
    func encode(_ value: UInt) throws   { try set(value, as: String(value)) }
    func encode(_ value: UInt8) throws  { try set(value, as: String(value)) }
    func encode(_ value: UInt16) throws { try set(value, as: String(value)) }
    func encode(_ value: UInt32) throws { try set(value, as: String(value)) }
    func encode(_ value: UInt64) throws { try set(value, as: String(value)) }

    private func set<T: Encodable>(_ value: T, as string: String) throws {
        guard canEncodeNewValue else {
            throw EncodingError.invalidValue(value, .init(codingPath: codingPath, debugDescription: "Already encoded."))
        }
        canEncodeNewValue = false
        context.component.set(to: .string(string), at: codingPath)
    }

    func encode<T: Encodable>(_ value: T) throws {
        switch value {
        case let decimal as Decimal:
            try set(value, as: String(describing: decimal))
        default:
            guard canEncodeNewValue else {
                throw EncodingError.invalidValue(value, .init(codingPath: codingPath, debugDescription: "Already encoded."))
            }
            canEncodeNewValue = false
            try value.encode(to: _URLEncodedFormEncoder(context: context, codingPath: codingPath))
        }
    }
}

// MARK: - Unkeyed container

extension _URLEncodedFormEncoder {
    final class UnkeyedContainer {
        var codingPath: [CodingKey]
        var count = 0
        private let context: URLEncodedFormContext

        init(context: URLEncodedFormContext, codingPath: [CodingKey]) {
            self.context = context
            self.codingPath = codingPath
        }

        var nestedCodingPath: [CodingKey] { codingPath + [AnyCodingKey(intValue: count)!] }
    }
}

extension _URLEncodedFormEncoder.UnkeyedContainer: UnkeyedEncodingContainer {
    func encodeNil() throws { count += 1 }

    func encode<T: Encodable>(_ value: T) throws {
        var container = nestedSingleValueContainer()
        try container.encode(value)
    }

    func nestedSingleValueContainer() -> SingleValueEncodingContainer {
        defer { count += 1 }
        return _URLEncodedFormEncoder.SingleValueContainer(context: context, codingPath: nestedCodingPath)
    }

    func nestedContainer<NK: CodingKey>(keyedBy keyType: NK.Type) -> KeyedEncodingContainer<NK> {
        defer { count += 1 }
        return KeyedEncodingContainer(_URLEncodedFormEncoder.KeyedContainer<NK>(context: context, codingPath: nestedCodingPath))
    }

    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        defer { count += 1 }
        return _URLEncodedFormEncoder.UnkeyedContainer(context: context, codingPath: nestedCodingPath)
    }

    func superEncoder() -> Encoder {
        defer { count += 1 }
        return _URLEncodedFormEncoder(context: context, codingPath: codingPath)
    }
}

// MARK: - Serializer

final class URLEncodedFormSerializer {
    private let keyEncoding: URLEncodedFormEncoder.KeyEncoding
    private let allowedCharacters: CharacterSet = .urlQueryAllowed

    init(keyEncoding: URLEncodedFormEncoder.KeyEncoding) {
        self.keyEncoding = keyEncoding
    }

    func serialize(_ object: URLEncodedFormComponent.Object) -> String {
        object.flatMap { serialize($0.value, forKey: $0.key) }.sorted().joined(separator: "&")
    }

    private func serialize(_ component: URLEncodedFormComponent, forKey key: String) -> [String] {
        switch component {
        case let .string(string):
            return ["\(escape(keyEncoding.encode(key)))=\(escape(string))"]
        case let .array(array):
            return array.flatMap { serialize($0, forKey: "\(key)[]") }.sorted()
        case let .object(object):
            return object.flatMap { serialize($0.value, forKey: "\(key)[\($0.key)]") }.sorted()
        }
    }

    private func escape(_ query: String) -> String {
        var allowed = allowedCharacters
        allowed.insert(charactersIn: " ")
        let escaped = query.addingPercentEncoding(withAllowedCharacters: allowed) ?? query
        return escaped.replacingOccurrences(of: " ", with: "%20")
    }
}

extension Array where Element == String {
    func joinedWithAmpersands() -> String {
        joined(separator: "&")
    }
}
