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
        config.protocolClasses = [UITestMockURLProtocol.self]
        loader = ImageLoader(urlSession: URLSession(configuration: config), cache: cache)

        imageView = UIImageView()
        testURL = URL(string: "https://uiimageview-test.example.com/img.png")!

        UITestMockURLProtocol.responseDelay = 0
        UITestMockURLProtocol.responseData = makeTestPNGData()
        UITestMockURLProtocol.statusCode = 200
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

    // MARK: - 9.4 Cell-reuse cancellation: only urlB's image is applied

    func test_loadImage_cellReuse_onlyLatestURLApplied() async throws {
        let urlA = URL(string: "https://uiimageview-test.example.com/a.png")!
        let urlB = URL(string: "https://uiimageview-test.example.com/b.png")!

        // A is slow; B is fast via L1 cache
        cache.storeInMemory(UIImage(data: makeTestPNGData())!, for: urlB)
        UITestMockURLProtocol.responseDelay = 0.5

        let expectationB = expectation(description: "B loaded")
        imageView.loadImage(from: urlA, loader: loader) // starts, will be cancelled
        imageView.loadImage(from: urlB, options: ImageLoadOptions(onCompletion: { _ in
            expectationB.fulfill()
        }), loader: loader)

        await fulfillment(of: [expectationB], timeout: 3)
        XCTAssertNotNil(imageView.image, "Image should be set to urlB's result")
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
        UITestMockURLProtocol.statusCode = 500
        UITestMockURLProtocol.responseData = Data()
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
        UITestMockURLProtocol.responseDelay = 0.5
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
        UITestMockURLProtocol.responseDelay = 0.5
        let options = ImageLoadOptions(placeholder: placeholder)
        imageView.loadImage(from: testURL, options: options, loader: loader)
        // After loadImage: image == placeholder
        imageView.cancelImageLoad()
        // After cancelImageLoad: image must still be placeholder (not nil, not different)
        XCTAssertEqual(imageView.image, placeholder, "cancelImageLoad must not change the displayed image")
    }
}

// MARK: - UITestMockURLProtocol (isolated from ImageLoaderTests mock)

final class UITestMockURLProtocol: URLProtocol {
    static var responseDelay: TimeInterval = 0
    static var statusCode: Int = 200
    static var responseData: Data?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        let delay = UITestMockURLProtocol.responseDelay
        let code = UITestMockURLProtocol.statusCode
        let data = UITestMockURLProtocol.responseData

        DispatchQueue.global().asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self else { return }
            let url = self.request.url ?? URL(string: "https://mock")!
            let response = HTTPURLResponse(url: url, statusCode: code, httpVersion: nil, headerFields: ["Content-Type": "image/png"])!
            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            if let data { self.client?.urlProtocol(self, didLoad: data) }
            self.client?.urlProtocolDidFinishLoading(self)
        }
    }

    override func stopLoading() {}
}

// MARK: - Local helper

private func makeTestPNGData() -> Data {
    UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { ctx in
        UIColor.green.setFill()
        ctx.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
    }.pngData()!
}
