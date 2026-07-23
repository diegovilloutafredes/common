import XCTest
import UIKit
@testable import Common

// Fixtures (makeTestImage / makeTestPNGData) live in ImageTestSupport.swift.

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

    // MARK: - Memory store/retrieve round-trip

    func test_storeAndRetrieveFromMemory() {
        let image = makeTestImage()
        cache.storeInMemory(image, for: url)
        // NSCache stores by reference — assert identity, not just presence
        // (a mutant returning UIImage() for any key passes a NotNil check),
        // and pin key correctness with an unrelated-URL miss.
        XCTAssertIdentical(cache.memoryImage(for: url), image)
        XCTAssertNil(cache.memoryImage(for: URL(string: "https://example.com/other.png")!))
    }

    // MARK: - clearAll empties memory and disk

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

    // MARK: - removeImage removes from L1 and disk

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

    // MARK: - Disk TTL: stale entry is deleted and returns nil

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

    // MARK: - Disk size cap: oldest files are evicted

    func test_diskSizeCap_evictsOldestFiles() async throws {
        // A 5-byte cap fits TWO 2-byte files, so the third write forces eviction
        // while two candidates are on disk — the only arrangement that proves
        // oldest-FIRST order (a 3-byte cap leaves one candidate per pass, and an
        // evict-newest-first bug would pass unnoticed).
        let tinyCache = ImageCache(diskCapacityLimit: 5, diskDirectory: tempDir)
        let url1 = URL(string: "https://example.com/a.png")!
        let url2 = URL(string: "https://example.com/b.png")!
        let url3 = URL(string: "https://example.com/c.png")!

        await tinyCache.storeToDisk(Data(repeating: 1, count: 2), for: url1, extension: "dat")
        // Ensure different modification dates
        try await Task.sleep(nanoseconds: 10_000_000)
        await tinyCache.storeToDisk(Data(repeating: 2, count: 2), for: url2, extension: "dat")
        try await Task.sleep(nanoseconds: 10_000_000)
        // 2+2+2 > 5: evicting the single oldest file (url1) is enough to fit.
        await tinyCache.storeToDisk(Data(repeating: 3, count: 2), for: url3, extension: "dat")

        let remaining = (try? FileManager.default.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: nil)) ?? []
        let keys = remaining.map { $0.deletingPathExtension().lastPathComponent }
        XCTAssertFalse(keys.contains(tinyCache.diskKey(for: url1)), "Oldest file must be the one evicted")
        XCTAssertTrue(keys.contains(tinyCache.diskKey(for: url2)), "Middle file must survive — its eviction means wrong order")
        XCTAssertTrue(keys.contains(tinyCache.diskKey(for: url3)), "Newest file should be present")
    }

    // MARK: - Disk-to-memory promotion

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
