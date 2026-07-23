import XCTest
import UIKit
@testable import Common

// MARK: - UIImageViewLoadImageTests

@MainActor
final class UIImageViewLoadImageTests: XCTestCase {

    private var loader: ImageLoader!
    private var cache: ImageCache!
    private var tempDir: URL!
    private var imageView: UIImageView!
    private var testURL: URL!

    override func setUp() {
        super.setUp()
        tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        cache = ImageCache(diskDirectory: tempDir)

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [ImageMockURLProtocol.self]
        loader = ImageLoader(urlSession: URLSession(configuration: config), cache: cache)

        imageView = UIImageView()
        testURL = URL(string: "https://uiimageview-test.example.com/img.png")!

        ImageMockURLProtocol.reset()
        ImageMockURLProtocol.responseData = makeTestPNGData()
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDir)
        imageView = nil
        loader = nil
        cache = nil
        super.tearDown()
    }

    // MARK: - 9.2 Basic load

    func test_loadImage_setsImageAfterFetch() async throws {
        let expectation = expectation(description: "onCompletion called")
        let options = ImageLoadOptions(onCompletion: { _ in expectation.fulfill() })
        imageView.loadImage(from: testURL, options: options, loader: loader)
        await fulfillment(of: [expectation], timeout: 3)
        XCTAssertNotNil(imageView.image)
    }

    // MARK: - 9.3 Placeholder shown synchronously

    func test_loadImage_showsPlaceholderImmediately() {
        let placeholder = UIImage(systemName: "photo")!
        let options = ImageLoadOptions(placeholder: placeholder)
        imageView.loadImage(from: testURL, options: options, loader: loader)
        XCTAssertEqual(imageView.image, placeholder, "Placeholder must be set synchronously")
    }

    // MARK: - 9.4 Cell-reuse cancellation: the stale slow result never lands

    func test_loadImage_cellReuse_staleSlowResultNeverLands() async throws {
        let urlA = URL(string: "https://uiimageview-test.example.com/a.png")!
        let urlB = URL(string: "https://uiimageview-test.example.com/b.png")!

        // A is slow (network); B is fast via L1 cache and a DISTINGUISHABLE instance —
        // asserting identity is what separates "B landed" from "A landed late".
        let imageB = UIImage(data: makeTestPNGData())!
        cache.storeInMemory(imageB, for: urlB)
        ImageMockURLProtocol.responseDelay = 0.5

        let expectationB = expectation(description: "B loaded")
        imageView.loadImage(from: urlA, loader: loader) // superseded by the reuse
        imageView.loadImage(from: urlB, options: ImageLoadOptions(onCompletion: { _ in
            expectationB.fulfill()
        }), loader: loader)

        await fulfillment(of: [expectationB], timeout: 3)
        XCTAssertTrue(imageView.image === imageB, "urlB's cached instance should be displayed")

        // The race this test exists for happens AFTER B lands: wait past A's slow
        // response and prove the stale image never overwrites B's.
        try await Task.sleep(nanoseconds: 700_000_000)
        XCTAssertTrue(imageView.image === imageB,
                      "the superseded slow load (urlA) must never overwrite the current image")
    }

    // MARK: - Cache hits skip the fade transition

    func test_loadImage_cacheHit_skipsFadeTransition() async throws {
        let cached = UIImage(data: makeTestPNGData())!
        cache.storeInMemory(cached, for: testURL)

        let done = expectation(description: "completion")
        let options = ImageLoadOptions(transition: .fade(0.25), onCompletion: { _ in done.fulfill() })
        imageView.loadImage(from: testURL, options: options, loader: loader)
        await fulfillment(of: [done], timeout: 3)

        // The final alpha alone can't discriminate (UIView.animate sets the model
        // alpha back to 1 synchronously) — the layer's attached animations can:
        // the fade path adds an opacity animation, the cache path must add none.
        XCTAssertEqual(imageView.alpha, 1, "cache hits must not animate")
        XCTAssertNil(imageView.layer.animationKeys(), "cache hits must not attach a fade animation")
        XCTAssertTrue(imageView.image === cached)
    }

    // MARK: - 9.5 onCompletion called with .success

    func test_loadImage_callsCompletionWithSuccess() async throws {
        let expectation = expectation(description: "success completion")
        var receivedResult: Result<UIImage, Error>?
        let options = ImageLoadOptions(onCompletion: { result in
            receivedResult = result
            expectation.fulfill()
        })
        imageView.loadImage(from: testURL, options: options, loader: loader)
        await fulfillment(of: [expectation], timeout: 3)

        guard case .success = receivedResult else {
            return XCTFail("Expected success, got \(String(describing: receivedResult))")
        }
    }

    // MARK: - 9.6 onCompletion called with .failure; failureImage is set

    func test_loadImage_callsCompletionWithFailure_andSetsFailureImage() async throws {
        ImageMockURLProtocol.statusCode = 500
        ImageMockURLProtocol.responseData = Data()
        let failureImage = UIImage(systemName: "xmark")!
        let expectation = expectation(description: "failure completion")
        var receivedResult: Result<UIImage, Error>?
        let options = ImageLoadOptions(failureImage: failureImage, onCompletion: { result in
            receivedResult = result
            expectation.fulfill()
        })
        imageView.loadImage(from: testURL, options: options, loader: loader)
        await fulfillment(of: [expectation], timeout: 3)

        guard case .failure = receivedResult else {
            return XCTFail("Expected failure, got \(String(describing: receivedResult))")
        }
        XCTAssertEqual(imageView.image, failureImage, "failureImage must be applied on error")
    }

    // MARK: - 9.7 Cancelled task does not call onCompletion

    func test_cancelImageLoad_doesNotCallCompletion() async throws {
        ImageMockURLProtocol.responseDelay = 0.5
        var completionCalled = false
        let options = ImageLoadOptions(onCompletion: { _ in completionCalled = true })
        imageView.loadImage(from: testURL, options: options, loader: loader)
        imageView.cancelImageLoad()

        try await Task.sleep(nanoseconds: 700_000_000)
        XCTAssertFalse(completionCalled, "Completion must not be called after explicit cancel")
    }

    // MARK: - 9.8 cancelImageLoad does not modify imageView.image

    func test_cancelImageLoad_doesNotModifyImage() {
        // loadImage sets placeholder synchronously; cancelImageLoad must not further modify the image
        let placeholder = UIImage(systemName: "star")!
        ImageMockURLProtocol.responseDelay = 0.5
        let options = ImageLoadOptions(placeholder: placeholder)
        imageView.loadImage(from: testURL, options: options, loader: loader)
        // After loadImage: image == placeholder
        imageView.cancelImageLoad()
        // After cancelImageLoad: image must still be placeholder (not nil, not different)
        XCTAssertEqual(imageView.image, placeholder, "cancelImageLoad must not change the displayed image")
    }
}

// ImageMockURLProtocol + makeTestPNGData live in ImageTestSupport.swift.
