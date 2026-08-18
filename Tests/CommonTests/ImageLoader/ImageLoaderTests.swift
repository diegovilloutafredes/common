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
        // reset() (not field-by-field) so the delivery gates the cancellation
        // tests install are cleared too — a lingering gate blocks every
        // subsequent request in the suite until URLSession times it out.
        ImageMockURLProtocol.reset()
        ImageMockURLProtocol.responseData = makeTestPNGData()
    }

    // MARK: - L1 cache-first

    func test_image_returnsFromMemory_withoutNetworkCall() async throws {
        let (loader, cache, url) = makeTestLoader(cleanupWith: self)
        cache.storeInMemory(UIImage(), for: url)

        _ = try await loader.image(for: url)

        XCTAssertEqual(ImageMockURLProtocol.requestCount, 0, "L1 hit must not hit network")
    }

    // MARK: - L2 cache-first

    func test_image_returnsFromDisk_withoutNetworkCall() async throws {
        let (loader, cache, url) = makeTestLoader(cleanupWith: self)
        let data = makeTestPNGData()
        await cache.storeToDisk(data, for: url, extension: "png")

        _ = try await loader.image(for: url)

        XCTAssertEqual(ImageMockURLProtocol.requestCount, 0, "L2 hit must not hit network")
    }

    // (L2 → L1 promotion is ImageCache behavior, covered by
    // ImageCacheTests.test_diskData_promotesToMemory; that the loader takes the
    // disk path at all is proven by the test above.)

    // MARK: - CachePolicy.reloadIgnoringCache bypasses both cache tiers

    func test_reloadIgnoringCache_fetchesFromNetwork_despiteCacheHit() async throws {
        let (loader, cache, url) = makeTestLoader(cleanupWith: self)
        cache.storeInMemory(UIImage(data: makeTestPNGData())!, for: url)

        let result = try await loader.imageResult(for: url, cachePolicy: .reloadIgnoringCache)

        XCTAssertEqual(ImageMockURLProtocol.requestCount, 1, "reloadIgnoringCache must skip L1/L2 and hit the network")
        XCTAssertEqual(result.source, .network)
    }

    // MARK: - Network fetch stores to L1 and L2

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

    // MARK: - Deduplication: two concurrent calls → one network request

    func test_deduplication_concurrentCalls_onlyOneNetworkRequest() async throws {
        ImageMockURLProtocol.responseDelay = 0.1
        let (loader, _, url) = makeTestLoader(cleanupWith: self)

        async let img1 = loader.image(for: url)
        async let img2 = loader.image(for: url)
        let (_, _) = try await (img1, img2)

        XCTAssertEqual(ImageMockURLProtocol.requestCount, 1, "Two concurrent calls should share one network request")
    }

    // MARK: - badResponse on 404

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

    // MARK: - decodingFailed on non-image data

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

    // MARK: - Preloading

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
        // Deterministic, not sleep-raced: the mock holds the response until the
        // test opens the gate, so a cancellation that only drops bookkeeping
        // (but lets the fetch complete) stores to cache and fails the assertion
        // on every run — a slow machine can no longer turn it false-green.
        let gate = DispatchSemaphore(value: 0)
        let resolved = DispatchSemaphore(value: 0)
        let stopSignal = DispatchSemaphore(value: 0)
        ImageMockURLProtocol.releaseGate = gate
        ImageMockURLProtocol.deliveryResolved = resolved
        ImageMockURLProtocol.stopSignal = stopSignal
        let (loader, cache, url) = makeTestLoader(cleanupWith: self)

        await loader.preload(urls: [url])
        await loader.cancelPreloads()
        // Cancellation reaches the mock asynchronously — wait for it (bounded:
        // a broken cancellation never stops the fetch, so the opened gate then
        // lets it deliver and fail the assertion below).
        _ = await wait(stopSignal, timeout: .now() + 5)
        gate.signal()
        _ = await wait(resolved, timeout: .now() + 10)

        XCTAssertNil(cache.memoryImage(for: url), "Cancelled preload must not populate cache")
    }

    // MARK: - Task cancellation

    func test_cancellation_doesNotDeliverImage() async throws {
        // Deterministic ordering: the fetch is verifiably in flight before the
        // cancel, the response is held until after it, and the task is fully
        // finished before the flag is judged — no sleep to race.
        let gate = DispatchSemaphore(value: 0)
        let resolved = DispatchSemaphore(value: 0)
        ImageMockURLProtocol.releaseGate = gate
        ImageMockURLProtocol.deliveryResolved = resolved
        let (loader, _, url) = makeTestLoader(cleanupWith: self)

        var completionCalled = false
        let task = Task {
            _ = try await loader.image(for: url)
            completionCalled = true
        }

        let started = await poll(timeout: 5) { ImageMockURLProtocol.requestCount >= 1 }
        XCTAssertTrue(started, "precondition: the fetch must be in flight before cancelling")
        task.cancel()
        gate.signal()
        _ = await wait(resolved, timeout: .now() + 10)
        _ = await task.result

        XCTAssertFalse(completionCalled, "Completion must not be called after cancellation")
    }

    // MARK: - Helpers

    /// Waits on a semaphore off the cooperative pool so an async test can block
    /// on mock-side events without starving the concurrency runtime.
    private func wait(_ semaphore: DispatchSemaphore, timeout: DispatchTime) async -> DispatchTimeoutResult {
        await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                continuation.resume(returning: semaphore.wait(timeout: timeout))
            }
        }
    }

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
