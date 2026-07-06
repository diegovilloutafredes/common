import XCTest
import UIKit
@testable import Common

// ImageMockURLProtocol + makeTestPNGData live in ImageTestSupport.swift.

// MARK: - Helpers

private func makeTestLoader(cleanupWith testCase: XCTestCase) -> (ImageLoader, ImageCache, URL) {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [ImageMockURLProtocol.self]
    let session = URLSession(configuration: config)
    let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
    // Sibling suites clean their temp dirs in tearDown; register cleanup at
    // creation so this suite stops leaking ~11 directories per run.
    testCase.addTeardownBlock { try? FileManager.default.removeItem(at: tempDir) }
    let cache = ImageCache(diskDirectory: tempDir)
    let loader = ImageLoader(urlSession: session, cache: cache)
    let url = URL(string: "https://mock.example.com/img.png")!
    return (loader, cache, url)
}

// MARK: - ImageLoaderTests

final class ImageLoaderTests: XCTestCase {

    override func setUp() {
        super.setUp()
        ImageMockURLProtocol.requestCount = 0
        ImageMockURLProtocol.responseDelay = 0
        ImageMockURLProtocol.statusCode = 200
        ImageMockURLProtocol.responseData = makeTestPNGData()
    }

    // MARK: - 8.2 L1 cache-first

    func test_image_returnsFromMemory_withoutNetworkCall() async throws {
        let (loader, cache, url) = makeTestLoader(cleanupWith: self)
        cache.storeInMemory(UIImage(), for: url)

        _ = try await loader.image(for: url)

        XCTAssertEqual(ImageMockURLProtocol.requestCount, 0, "L1 hit must not hit network")
    }

    // MARK: - 8.3 L2 cache-first

    func test_image_returnsFromDisk_withoutNetworkCall() async throws {
        let (loader, cache, url) = makeTestLoader(cleanupWith: self)
        let data = makeTestPNGData()
        await cache.storeToDisk(data, for: url, extension: "png")

        let image = try await loader.image(for: url)

        XCTAssertNotNil(image)
        XCTAssertEqual(ImageMockURLProtocol.requestCount, 0, "L2 hit must not hit network")
    }

    // MARK: - 8.4 L2 → L1 promotion

    func test_diskHit_promotesToL1() async throws {
        let (loader, cache, url) = makeTestLoader(cleanupWith: self)
        let data = makeTestPNGData()
        await cache.storeToDisk(data, for: url, extension: "png")

        _ = try await loader.image(for: url)

        XCTAssertNotNil(cache.memoryImage(for: url), "Disk hit should promote to L1")
    }

    // MARK: - 8.5 Network fetch stores to L1 and L2

    func test_networkFetch_storesToL1AndL2() async throws {
        let (loader, cache, url) = makeTestLoader(cleanupWith: self)

        _ = try await loader.image(for: url)
        XCTAssertEqual(ImageMockURLProtocol.requestCount, 1)

        // L1 is populated synchronously during the fetch.
        XCTAssertNotNil(cache.memoryImage(for: url), "Network fetch must store to L1")

        // L2 is written on a detached Task — poll until it lands rather than waiting a fixed time.
        let storedToDisk = await poll(timeout: 2) { await cache.diskData(for: url) != nil }
        XCTAssertTrue(storedToDisk, "Network fetch must store to L2 (disk)")
    }

    // MARK: - 8.6 Deduplication: two concurrent calls → one network request

    func test_deduplication_concurrentCalls_onlyOneNetworkRequest() async throws {
        ImageMockURLProtocol.responseDelay = 0.1
        let (loader, _, url) = makeTestLoader(cleanupWith: self)

        async let img1 = loader.image(for: url)
        async let img2 = loader.image(for: url)
        let (_, _) = try await (img1, img2)

        XCTAssertEqual(ImageMockURLProtocol.requestCount, 1, "Two concurrent calls should share one network request")
    }

    // MARK: - 8.7 badResponse on 404

    func test_image_throws_badResponse_on404() async throws {
        ImageMockURLProtocol.statusCode = 404
        ImageMockURLProtocol.responseData = Data()
        let (loader, _, url) = makeTestLoader(cleanupWith: self)

        do {
            _ = try await loader.image(for: url)
            XCTFail("Expected ImageLoaderError.badResponse")
        } catch ImageLoaderError.badResponse(let code) {
            XCTAssertEqual(code, 404)
        }
    }

    // MARK: - 8.8 decodingFailed on non-image data

    func test_image_throws_decodingFailed_onNonImageData() async throws {
        ImageMockURLProtocol.responseData = "not an image".data(using: .utf8)
        let (loader, _, url) = makeTestLoader(cleanupWith: self)

        do {
            _ = try await loader.image(for: url)
            XCTFail("Expected ImageLoaderError.decodingFailed")
        } catch ImageLoaderError.decodingFailed {
            // pass
        }
    }

    // MARK: - 8.10 Preloading

    func test_preload_populatesL1Cache() async throws {
        let (loader, cache, url) = makeTestLoader(cleanupWith: self)

        await loader.preload(urls: [url])
        // Join the in-flight fetch (or hit L1 if preload already finished) — deterministic
        _ = try? await loader.image(for: url)

        XCTAssertNotNil(cache.memoryImage(for: url), "Preloaded image must be in L1 cache")
        XCTAssertEqual(ImageMockURLProtocol.requestCount, 1, "Preload must trigger exactly one network request")
    }

    func test_preload_deduplicates_withConcurrentNormalLoad() async throws {
        ImageMockURLProtocol.responseDelay = 0.1
        let (loader, _, url) = makeTestLoader(cleanupWith: self)

        await loader.preload(urls: [url])
        _ = try await loader.image(for: url)

        XCTAssertEqual(ImageMockURLProtocol.requestCount, 1, "Preload + normal load for same URL must share one request")
    }

    func test_cancelPreloads_stopsFetch() async throws {
        ImageMockURLProtocol.responseDelay = 1.0
        let (loader, cache, url) = makeTestLoader(cleanupWith: self)

        await loader.preload(urls: [url])
        await loader.cancelPreloads()
        // Wait PAST the mock's full response delay: a cancellation that only
        // drops bookkeeping (but lets the fetch complete) stores to cache at
        // ~1.0s and must fail this assertion.
        try await Task.sleep(nanoseconds: 2_000_000_000)

        XCTAssertNil(cache.memoryImage(for: url), "Cancelled preload must not populate cache")
    }

    // MARK: - 8.9 Task cancellation

    func test_cancellation_doesNotDeliverImage() async throws {
        ImageMockURLProtocol.responseDelay = 1.0
        let (loader, _, url) = makeTestLoader(cleanupWith: self)

        var completionCalled = false
        let task = Task {
            _ = try await loader.image(for: url)
            completionCalled = true
        }

        try await Task.sleep(nanoseconds: 50_000_000) // 50ms — before response arrives
        task.cancel()

        // Wait PAST the mock's full response delay — asserting earlier would
        // pass even if cancellation did nothing (the response hadn't fired yet).
        try await Task.sleep(nanoseconds: 1_300_000_000)

        XCTAssertFalse(completionCalled, "Completion must not be called after cancellation")
    }

    // MARK: - Helpers

    /// Polls `condition` until it returns true or `timeout` elapses. Returns the final result.
    /// Used to await detached side effects (e.g. disk writes) without a brittle fixed sleep.
    private func poll(timeout: TimeInterval, until condition: () async -> Bool) async -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if await condition() { return true }
            try? await Task.sleep(nanoseconds: 10_000_000)
        }
        return await condition()
    }
}
