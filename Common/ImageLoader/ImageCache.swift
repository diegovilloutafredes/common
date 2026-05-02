import UIKit
import CryptoKit

/// Two-tier image cache: L1 `NSCache` (memory) + L2 `FileManager` disk.
public final class ImageCache {

    // MARK: - L1 Memory

    private let memoryCache = NSCache<NSString, UIImage>()

    /// Maximum total cost (bytes) for the memory cache. Default 50 MB.
    public let memoryCostLimit: Int

    // MARK: - L2 Disk

    private let diskDirectory: URL
    /// Maximum total size (bytes) of all disk-cached files. Default 150 MB.
    public let diskCapacityLimit: Int
    /// Disk entries older than this are treated as expired. Default 7 days.
    public let diskTTL: TimeInterval

    // MARK: - Init

    public init(
        memoryCostLimit: Int = 50 * 1024 * 1024,
        diskCapacityLimit: Int = 150 * 1024 * 1024,
        diskTTL: TimeInterval = 7 * 24 * 60 * 60,
        diskDirectory: URL? = nil
    ) {
        self.memoryCostLimit = memoryCostLimit
        self.diskCapacityLimit = diskCapacityLimit
        self.diskTTL = diskTTL

        if let dir = diskDirectory {
            self.diskDirectory = dir
        } else {
            let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            let bundleId = Bundle.main.bundleIdentifier ?? "common"
            self.diskDirectory = caches.appendingPathComponent(bundleId).appendingPathComponent("CommonImageCache")
        }

        memoryCache.totalCostLimit = memoryCostLimit

        try? FileManager.default.createDirectory(at: self.diskDirectory, withIntermediateDirectories: true)
    }

    // MARK: - L1 Memory

    /// Stores a decoded image in the memory cache.
    public func storeInMemory(_ image: UIImage, for url: URL) {
        let cost = (image.cgImage?.bytesPerRow ?? 0) * (image.cgImage?.height ?? 0)
        memoryCache.setObject(image, forKey: url.absoluteString as NSString, cost: cost)
    }

    /// Returns a cached image from memory, or `nil` if not present.
    public func memoryImage(for url: URL) -> UIImage? {
        memoryCache.object(forKey: url.absoluteString as NSString)
    }

    // MARK: - L2 Disk

    /// Returns the SHA256-hex filename (without extension) for a URL.
    func diskKey(for url: URL) -> String {
        let data = Data(url.absoluteString.utf8)
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private func diskPath(for url: URL, extension ext: String) -> URL {
        diskDirectory.appendingPathComponent(diskKey(for: url)).appendingPathExtension(ext)
    }

    /// Writes raw response data to disk asynchronously.
    /// Enforces the size cap before writing; sets modification date to now.
    public func storeToDisk(_ data: Data, for url: URL, extension ext: String) async {
        let filePath = diskPath(for: url, extension: ext)
        await evictIfNeeded(toFit: data.count)
        try? data.write(to: filePath)
    }

    /// Returns raw disk data for a URL if present and within TTL; deletes stale entries.
    /// On a hit, decodes and promotes the image to L1 memory cache as a side effect.
    public func diskData(for url: URL) async -> Data? {
        // Find the file regardless of extension (SHA256 key prefix match)
        let key = diskKey(for: url)
        guard let filePath = firstFile(withKey: key) else { return nil }

        let attrs = try? FileManager.default.attributesOfItem(atPath: filePath.path)
        let modified = attrs?[.modificationDate] as? Date ?? .distantPast
        if Date().timeIntervalSince(modified) > diskTTL {
            try? FileManager.default.removeItem(at: filePath)
            return nil
        }
        // Touch modification date to mark recent access
        try? FileManager.default.setAttributes([.modificationDate: Date()], ofItemAtPath: filePath.path)
        guard let data = try? Data(contentsOf: filePath) else { return nil }
        // Promote to L1 on hit
        if let image = UIImage(data: data) {
            storeInMemory(image, for: url)
        }
        return data
    }

    /// Removes only the L1 memory entry for a URL, leaving the disk file intact.
    public func removeMemoryImage(for url: URL) {
        memoryCache.removeObject(forKey: url.absoluteString as NSString)
    }

    /// Removes the L1 entry and the corresponding disk file for a URL.
    public func removeImage(for url: URL) {
        memoryCache.removeObject(forKey: url.absoluteString as NSString)
        let key = diskKey(for: url)
        if let filePath = firstFile(withKey: key) {
            try? FileManager.default.removeItem(at: filePath)
        }
    }

    /// Clears all L1 entries and deletes the entire disk cache directory.
    public func clearAll() {
        memoryCache.removeAllObjects()
        try? FileManager.default.removeItem(at: diskDirectory)
        try? FileManager.default.createDirectory(at: diskDirectory, withIntermediateDirectories: true)
    }

    // MARK: - Private helpers

    private func firstFile(withKey key: String) -> URL? {
        let contents = (try? FileManager.default.contentsOfDirectory(
            at: diskDirectory,
            includingPropertiesForKeys: nil
        )) ?? []
        return contents.first { $0.deletingPathExtension().lastPathComponent == key }
    }

    private func evictIfNeeded(toFit newBytes: Int) async {
        let fm = FileManager.default
        let contents = (try? fm.contentsOfDirectory(
            at: diskDirectory,
            includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey]
        )) ?? []

        var totalSize = contents.reduce(0) { sum, url in
            sum + ((try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0)
        }

        guard totalSize + newBytes > diskCapacityLimit else { return }

        // Sort by modification date ascending (oldest first)
        let sorted = contents.sorted { a, b in
            let aDate = (try? a.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
            let bDate = (try? b.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
            return aDate < bDate
        }

        for file in sorted {
            guard totalSize + newBytes > diskCapacityLimit else { break }
            let size = (try? file.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
            try? fm.removeItem(at: file)
            totalSize -= size
        }
    }
}
