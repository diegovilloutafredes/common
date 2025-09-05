//
//  FileStorage.swift
//

import Foundation

// MARK: - FileStorage
public struct FileStorage: KeyValueStorage {
    public static var shared = FileStorage()
    private init() {}
}

extension FileStorage {
    public func add(item: KeyValue<Storable>, completion: CompletionHandler) {
        guard
            let data = item.value.asData(),
            let fileURL = fileURL(using: item.key)
        else { return }
        try? data.write(to: fileURL)
        completion?()
    }

    public func add(item: KeyStorable, completion: CompletionHandler) {
        add(item: (item.key, item), completion: completion)
    }

    public func get<T: Storable>(using key: String) -> T? {
        guard let fileURL = fileURL(using: key) else { return nil }
        return try? Data(contentsOf: fileURL).decoded()
    }

    public func remove(using key: String, completion: CompletionHandler) {
        guard let fileURL = fileURL(using: key) else { return }
        try? FileManager.default.removeItem(at: fileURL)
        completion?()
    }
}

extension FileStorage {
    private func fileURL(using pathComponent: String) -> URL? { URL.documentsDirectory?.appendingPathComponent(pathComponent) }
}
