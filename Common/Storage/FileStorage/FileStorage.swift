//
//  FileStorage.swift
//

import Foundation

// MARK: - FileStorage

/// A storage implementation that persists codable objects to the file system.
///
/// - Important: `FileStorage` is **not thread-safe**. `shared` is an
///   unsynchronized mutable static, and reads/writes go straight to disk with
///   no locking — concurrent access to the same key from multiple threads can
///   interleave. Confine usage of a given key to a single thread (typically
///   the main thread), or add external synchronization.
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
        ensureDirectoryExists(for: fileURL)
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
            ensureDirectoryExists(for: url)
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

    /// `URL.documentsDirectory` returns the container path whether or not the
    /// directory exists on disk. In environments where it hasn't been created
    /// yet (fresh app containers, simulator test hosts) `Data.write(to:)` fails
    /// — silently, under the fire-and-forget API — and the value is dropped.
    private func ensureDirectoryExists(for fileURL: URL) {
        try? FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
    }
}
