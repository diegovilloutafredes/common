import XCTest
import UIKit
@testable import Common

// MARK: - ImageMockURLProtocol

final class ImageMockURLProtocol: URLProtocol {
    static var requestCount = 0
    static var responseDelay: TimeInterval = 0
    static var statusCode: Int = 200
    static var responseData: Data?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        ImageMockURLProtocol.requestCount += 1
        let delay = ImageMockURLProtocol.responseDelay
        let code = ImageMockURLProtocol.statusCode
        let data = ImageMockURLProtocol.responseData

        DispatchQueue.global().asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self else { return }
            let url = self.request.url ?? URL(string: "https://mock")!
            let response = HTTPURLResponse(url: url, statusCode: code, httpVersion: nil, headerFields: ["Content-Type": "image/png"])!
            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            if let data {
                self.client?.urlProtocol(self, didLoad: data)
            }
            self.client?.urlProtocolDidFinishLoading(self)
        }
    }

    override func stopLoading() {}
}

// MARK: - Helpers

private func makeTestPNGData() -> Data {
    UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { ctx in
        UIColor.blue.setFill()
        ctx.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
    }.pngData()!
}

private func makeTestLoader() -> (ImageLoader, ImageCache, URL) {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [ImageMockURLProtocol.self]
    let session = URLSession(configuration: config)
    let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
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
        let (loader, cache, url) = makeTestLoader()
        cache.storeInMemory(UIImage(), for: url)

        _ = try await loader.image(for: url)

        XCTAssertEqual(ImageMockURLProtocol.requestCount, 0, "L1 hit must not hit network")
    }

    // MARK: - 8.3 L2 cache-first

    func test_image_returnsFromDisk_withoutNetworkCall() async throws {
        let (loader, cache, url) = makeTestLoader()
        let data = makeTestPNGData()
        await cache.storeToDisk(data, for: url, extension: "png")

        let image = try await loader.image(for: url)

        XCTAssertNotNil(image)
        XCTAssertEqual(ImageMockURLProtocol.requestCount, 0, "L2 hit must not hit network")
    }

    // MARK: - 8.4 L2 → L1 promotion

    func test_diskHit_promotesToL1() async throws {
        let (loader, cache, url) = makeTestLoader()
        let data = makeTestPNGData()
        await cache.storeToDisk(data, for: url, extension: "png")

        _ = try await loader.image(for: url)

        XCTAssertNotNil(cache.memoryImage(for: url), "Disk hit should promote to L1")
    }

    // MARK: - 8.5 Network fetch stores to L1 and L2

    func test_networkFetch_storesToL1AndL2() async throws {
        let (loader, cache, url) = makeTestLoader()

        _ = try await loader.image(for: url)
        XCTAssertEqual(ImageMockURLProtocol.requestCount, 1)

        // The disk write is a detached Task — give it time to land before clearing L1
        try await Task.sleep(nanoseconds: 100_000_000)

        cache.removeMemoryImage(for: url)
        ImageMockURLProtocol.requestCount = 0

        _ = try await loader.image(for: url)
        XCTAssertEqual(ImageMockURLProtocol.requestCount, 0, "After clearing L1, disk should serve")
    }

    // MARK: - 8.6 Deduplication: two concurrent calls → one network request

    func test_deduplication_concurrentCalls_onlyOneNetworkRequest() async throws {
        ImageMockURLProtocol.responseDelay = 0.1
        let (loader, _, url) = makeTestLoader()

        async let img1 = loader.image(for: url)
        async let img2 = loader.image(for: url)
        let (_, _) = try await (img1, img2)

        XCTAssertEqual(ImageMockURLProtocol.requestCount, 1, "Two concurrent calls should share one network request")
    }

    // MARK: - 8.7 badResponse on 404

    func test_image_throws_badResponse_on404() async throws {
        ImageMockURLProtocol.statusCode = 404
        ImageMockURLProtocol.responseData = Data()
        let (loader, _, url) = makeTestLoader()

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
        let (loader, _, url) = makeTestLoader()

        do {
            _ = try await loader.image(for: url)
            XCTFail("Expected ImageLoaderError.decodingFailed")
        } catch ImageLoaderError.decodingFailed {
            // pass
        }
    }

    // MARK: - 8.10 Preloading

    func test_preload_populatesL1Cache() async throws {
        let (loader, cache, url) = makeTestLoader()

        await loader.preload(urls: [url])
        // Join the in-flight fetch (or hit L1 if preload already finished) — deterministic
        _ = try? await loader.image(for: url)

        XCTAssertNotNil(cache.memoryImage(for: url), "Preloaded image must be in L1 cache")
        XCTAssertEqual(ImageMockURLProtocol.requestCount, 1, "Preload must trigger exactly one network request")
    }

    func test_preload_deduplicates_withConcurrentNormalLoad() async throws {
        ImageMockURLProtocol.responseDelay = 0.1
        let (loader, _, url) = makeTestLoader()

        await loader.preload(urls: [url])
        _ = try await loader.image(for: url)

        XCTAssertEqual(ImageMockURLProtocol.requestCount, 1, "Preload + normal load for same URL must share one request")
    }

    func test_cancelPreloads_stopsFetch() async throws {
        ImageMockURLProtocol.responseDelay = 1.0
        let (loader, cache, url) = makeTestLoader()

        await loader.preload(urls: [url])
        await loader.cancelPreloads()
        try await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertNil(cache.memoryImage(for: url), "Cancelled preload must not populate cache")
    }

    // MARK: - 8.9 Task cancellation

    func test_cancellation_doesNotDeliverImage() async throws {
        ImageMockURLProtocol.responseDelay = 1.0
        let (loader, _, url) = makeTestLoader()

        var completionCalled = false
        let task = Task {
            _ = try await loader.image(for: url)
            completionCalled = true
        }

        try await Task.sleep(nanoseconds: 50_000_000) // 50ms — before response arrives
        task.cancel()

        try await Task.sleep(nanoseconds: 200_000_000) // wait for mock to fire

        XCTAssertFalse(completionCalled, "Completion must not be called after cancellation")
    }
}
