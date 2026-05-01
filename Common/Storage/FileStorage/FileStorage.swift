//
//  FileStorage.swift
//

import Foundation

// MARK: - FileStorage

/// A class responsible for storing and retrieving codable objects to and from the file system.
// MARK: - FileStorage
/// A storage implementation using the file system.
public struct FileStorage: KeyValueStorage {
    
    /// The shared instance of `FileStorage`.
    public static var shared = FileStorage()
    
    private init() {}
}

extension FileStorage {
    
    /// Adds a key-value pair to storage.
    /// - Parameter item: The key-value pair to add.
    public func add(item: KeyValue<Storable>) {
        guard
            let data = item.value.asData(),
            let fileURL = fileURL(using: item.key)
        else { return }
        try? data.write(to: fileURL)
    }

    /// Adds a `KeyStorable` item to storage.
    /// - Parameter item: The item to add.
    public func add(item: KeyStorable) {
        add(item: (item.key, item))
    }

    /// Retrieves an item from storage.
    /// - Parameter key: The key identifying the item.
    /// - Returns: The stored item, or `nil` if not found.
    public func get<T: Storable>(using key: String) -> T? {
        guard let fileURL = fileURL(using: key) else { return nil }
        return try? Data(contentsOf: fileURL).decoded()
    }

    /// Removes an item from storage.
    /// - Parameter key: The key identifying the item to remove.
    public func remove(using key: String) {
        guard let fileURL = fileURL(using: key) else { return }
        try? FileManager.default.removeItem(at: fileURL)
    }

    // MARK: - Result-based API

    public func tryAdd(item: KeyValue<Storable>) -> Result<Void, StorageError> {
        guard let data = item.value.asData() else {
            return .failure(.encodingFailed(CocoaError(.coderInvalidValue)))
        }
        guard let url = fileURL(using: item.key) else {
            return .failure(.fileIOError(CocoaError(.fileWriteUnknown)))
        }
        do {
            try data.write(to: url)
            return .success(())
        } catch {
            return .failure(.fileIOError(error))
        }
    }

    public func tryGet<T: Storable>(using key: String) -> Result<T?, StorageError> {
        guard let url = fileURL(using: key),
              FileManager.default.fileExists(atPath: url.path) else {
            return .success(nil)
        }
        do {
            let data = try Data(contentsOf: url)
            guard let value: T = data.decoded() else {
                return .failure(.decodingFailed(CocoaError(.coderReadCorrupt)))
            }
            return .success(value)
        } catch {
            return .failure(.fileIOError(error))
        }
    }

    public func tryRemove(using key: String) -> Result<Void, StorageError> {
        guard let url = fileURL(using: key),
              FileManager.default.fileExists(atPath: url.path) else {
            return .success(())
        }
        do {
            try FileManager.default.removeItem(at: url)
            return .success(())
        } catch {
            return .failure(.fileIOError(error))
        }
    }
}

extension FileStorage {
    private func fileURL(using pathComponent: String) -> URL? { URL.documentsDirectory?.appendingPathComponent(pathComponent) }
}
