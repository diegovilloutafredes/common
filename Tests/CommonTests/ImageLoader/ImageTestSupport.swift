//
//  ImageTestSupport.swift
//
//  Shared fixtures + mock for the ImageLoader/ImageCache/UIImageView+LoadImage suites.
//  Consolidates the previously-triplicated makeTestPNGData and the two near-identical
//  mock URLProtocols. Cross-test isolation is preserved by each suite calling
//  `ImageMockURLProtocol.reset()` in setUp (XCTest runs test methods sequentially).
//

import UIKit
import Foundation

func makeTestImage(size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
    UIGraphicsImageRenderer(size: size).image { ctx in
        UIColor.red.setFill()
        ctx.fill(CGRect(origin: .zero, size: size))
    }
}

func makeTestPNGData(size: CGSize = CGSize(width: 1, height: 1)) -> Data {
    makeTestImage(size: size).pngData()!
}

// MARK: - ImageMockURLProtocol

/// Field-based mock URLProtocol shared by the image test suites. Delivers a synthetic
/// HTTP response after `responseDelay`, counting requests for cache-hit assertions.
final class ImageMockURLProtocol: URLProtocol {
    static var requestCount = 0
    static var responseDelay: TimeInterval = 0
    static var statusCode: Int = 200
    static var responseData: Data?

    /// Resets all static state to defaults. Call in each suite's setUp.
    static func reset() {
        requestCount = 0
        responseDelay = 0
        statusCode = 200
        responseData = nil
    }

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
