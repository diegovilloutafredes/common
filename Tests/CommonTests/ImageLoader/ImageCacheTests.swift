import XCTest
import UIKit
@testable import Common

// MARK: - Helpers

private func makeTestImage(size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
    UIGraphicsImageRenderer(size: size).image { ctx in
        UIColor.red.setFill()
        ctx.fill(CGRect(origin: .zero, size: size))
    }
}

private func makeTestPNGData(size: CGSize = CGSize(width: 1, height: 1)) -> Data {
    makeTestImage(size: size).pngData()!
}

// MARK: - ImageCacheTests

final class ImageCacheTests: XCTestCase {

    private var tempDir: URL!
    private var cache: ImageCache!
    private let url = URL(string: "https://example.com/image.png")!

    override func setUp() {
        super.setUp()
        tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        cache = ImageCache(diskDirectory: tempDir)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDir)
        cache = nil
        super.tearDown()
    }

    // MARK: - 7.2 Memory store/retrieve round-trip

    func test_storeAndRetrieveFromMemory() {
        let image = makeTestImage()
        cache.storeInMemory(image, for: url)
        XCTAssertNotNil(cache.memoryImage(for: url))
    }

    // MARK: - 7.3 clearAll empties memory and disk

    func test_clearAll_emptiesMemoryAndDisk() async {
        let image = makeTestImage()
        let data = makeTestPNGData()
        cache.storeInMemory(image, for: url)
        await cache.storeToDisk(data, for: url, extension: "png")

        cache.clearAll()

        XCTAssertNil(cache.memoryImage(for: url))
        let diskResult = await cache.diskData(for: url)
        XCTAssertNil(diskResult)
    }

    // MARK: - 7.4 removeImage removes from L1 and disk

    func test_removeImage_removesFromMemoryAndDisk() async {
        let image = makeTestImage()
        let data = makeTestPNGData()
        cache.storeInMemory(image, for: url)
        await cache.storeToDisk(data, for: url, extension: "png")

        cache.removeImage(for: url)

        XCTAssertNil(cache.memoryImage(for: url))
        let diskResult = await cache.diskData(for: url)
        XCTAssertNil(diskResult)
    }

    // MARK: - 7.5 Disk TTL: stale entry is deleted and returns nil

    func test_diskData_staleEntry_returnsNilAndDeletesFile() async throws {
        let data = makeTestPNGData()
        await cache.storeToDisk(data, for: url, extension: "png")

        // Backdate the file's modification date past the TTL
        let key = cache.diskKey(for: url)
        let contents = try FileManager.default.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: nil)
        let file = try XCTUnwrap(contents.first { $0.deletingPathExtension().lastPathComponent == key })
        let pastDate = Date(timeIntervalSinceNow: -(cache.diskTTL + 1))
        try FileManager.default.setAttributes([.modificationDate: pastDate], ofItemAtPath: file.path)

        let result = await cache.diskData(for: url)
        XCTAssertNil(result, "Stale entry should return nil")

        // File must be deleted
        XCTAssertFalse(FileManager.default.fileExists(atPath: file.path), "Stale file must be removed")
    }

    // MARK: - 7.6 Disk size cap: oldest files are evicted

    func test_diskSizeCap_evictsOldestFiles() async throws {
        // Use a 3-byte cap so even tiny files exceed it
        let tinyCache = ImageCache(diskCapacityLimit: 3, diskDirectory: tempDir)
        let url1 = URL(string: "https://example.com/a.png")!
        let url2 = URL(string: "https://example.com/b.png")!
        let url3 = URL(string: "https://example.com/c.png")!

        let data1 = Data(repeating: 1, count: 2)
        let data2 = Data(repeating: 2, count: 2)
        let data3 = Data(repeating: 3, count: 2)

        await tinyCache.storeToDisk(data1, for: url1, extension: "dat")
        // Ensure different modification dates
        try await Task.sleep(nanoseconds: 10_000_000)
        await tinyCache.storeToDisk(data2, for: url2, extension: "dat")
        try await Task.sleep(nanoseconds: 10_000_000)
        // Writing data3 (2 bytes) should cause data1 to be evicted (oldest)
        await tinyCache.storeToDisk(data3, for: url3, extension: "dat")

        let remaining = (try? FileManager.default.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: nil)) ?? []
        let keys = remaining.map { $0.deletingPathExtension().lastPathComponent }
        XCTAssertFalse(keys.contains(tinyCache.diskKey(for: url1)), "Oldest file should be evicted")
        XCTAssertTrue(keys.contains(tinyCache.diskKey(for: url3)), "Newest file should be present")
    }

    // MARK: - 7.7 Disk-to-memory promotion

    func test_diskData_promotesToMemory() async throws {
        let data = makeTestPNGData()
        // storeToDisk does not touch L1 — only disk gets the data
        await cache.storeToDisk(data, for: url, extension: "png")

        // Confirm L1 is empty before the test
        XCTAssertNil(cache.memoryImage(for: url), "L1 must be empty before test")

        let result = await cache.diskData(for: url)
        XCTAssertNotNil(result, "Disk hit should return data")
        // Promotion: L1 should now contain the image as a side effect
        XCTAssertNotNil(cache.memoryImage(for: url), "Disk hit should promote image to L1")
    }
}
