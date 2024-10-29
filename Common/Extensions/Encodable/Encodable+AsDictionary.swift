//
//  Encodable+AsDictionary.swift
//

import Foundation

//extension Encodable {
//    var asDictionary: [String: Any]? {
//        guard let encoded else { return nil }
//        return (try? JSONSerialization.jsonObject(with: encoded)) as? [String: Any]
//    }
//}

extension Encodable {
    public var asDictionary: [String: Any]? {
        guard let data = try? JSONEncoder().keyEncodingStrategy(.convertToSnakeCase).encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
    }
}
