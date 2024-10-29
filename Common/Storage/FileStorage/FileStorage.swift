//
//  FileStorage.swift
//

import Foundation

// MARK: - FileStorage
public struct FileStorage: KeyValueStorage {
    static var shared = FileStorage()
    private init() {}
}

extension FileStorage {
    public func add(item: KeyValue<Storable>, completion: CompletionHandler) {
        guard
            let data = item.value.encoded,
            let documentsDirectory = URL.documentsDirectory
        else { return }
        let fileURL = documentsDirectory.appendingPathComponent(item.key)
        try? data.write(to: fileURL)
        completion?()
    }

    public func add(item: KeyStorable, completion: CompletionHandler) {
        add(item: (item.key, item), completion: completion)
    }

    public func get<T: Storable>(using key: String) -> T? {
        guard let documentsDirectory = URL.documentsDirectory else { return nil }
        let fileURL = documentsDirectory.appendingPathComponent(key)
        return try? Data(contentsOf: fileURL).decoded()
    }

    public func remove(using key: String, completion: CompletionHandler) {
        guard let documentsDirectory = URL.documentsDirectory else { return }
        let fileURL = documentsDirectory.appendingPathComponent(key)
        try? FileManager.default.removeItem(at: fileURL)
        completion?()
    }
}
