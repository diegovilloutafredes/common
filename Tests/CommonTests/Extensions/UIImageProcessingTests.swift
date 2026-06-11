//
//  UIImageProcessingTests.swift
//

import UIKit
import XCTest
@testable import Common

/// Pins the behavior of the image-processing extensions using small in-memory
/// solid-color fixtures (scale 1, so points == pixels) — asserting dimensions,
/// orientation, and coarse color rather than pixel-exact output.
final class UIImageProcessingTests: XCTestCase {

    /// A solid-color image at scale 1 so point sizes equal pixel sizes.
    private func solidImage(_ color: UIColor, width: CGFloat = 40, height: CGFloat = 20) -> UIImage {
        let size = CGSize(width: width, height: height)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }

    private func assertColor(_ color: UIColor?, isCloseTo expected: (r: CGFloat, g: CGFloat, b: CGFloat), accuracy: CGFloat = 0.05, line: UInt = #line) {
        guard let color else { return XCTFail("Expected a color", line: line) }
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        XCTAssertEqual(r, expected.r, accuracy: accuracy, line: line)
        XCTAssertEqual(g, expected.g, accuracy: accuracy, line: line)
        XCTAssertEqual(b, expected.b, accuracy: accuracy, line: line)
    }

    // MARK: - rotate(radians:)

    func test_rotate_quarterTurn_swapsDimensions() {
        let rotated = solidImage(.red).rotate(radians: .pi / 2)
        XCTAssertEqual(rotated?.size.width, 20)
        XCTAssertEqual(rotated?.size.height, 40)
    }

    func test_rotate_halfTurn_keepsDimensions() {
        let rotated = solidImage(.red).rotate(radians: .pi)
        XCTAssertEqual(rotated?.size.width, 40)
        XCTAssertEqual(rotated?.size.height, 20)
    }

    // MARK: - cropped(to:)

    func test_cropped_returnsRequestedPixelRegion() {
        let cropped = solidImage(.blue).cropped(to: .init(x: 0, y: 0, width: 10, height: 8))
        XCTAssertEqual(cropped?.cgImage?.width, 10)
        XCTAssertEqual(cropped?.cgImage?.height, 8)
    }

    func test_cropped_outsideBounds_returnsNil() {
        XCTAssertNil(solidImage(.blue).cropped(to: .init(x: 100, y: 100, width: 10, height: 10)))
    }

    // MARK: - fixOrientation()

    func test_fixOrientation_upImage_returnsEqualImage() {
        let image = solidImage(.green)
        let fixed = image.fixOrientation()
        XCTAssertEqual(fixed?.imageOrientation, .up)
        XCTAssertEqual(fixed?.size, image.size)
    }

    func test_fixOrientation_leftOrientedImage_redrawsAsUp() {
        guard let cgImage = solidImage(.green).cgImage
        else { return XCTFail("Expected a cgImage") }
        let oriented = UIImage(cgImage: cgImage, scale: 1, orientation: .left)

        let fixed = oriented.fixOrientation()
        XCTAssertEqual(fixed?.imageOrientation, .up)
        XCTAssertEqual(fixed?.size, oriented.size, "fixed image should keep the oriented (display) size")
    }

    // MARK: - convertToGrayScale()

    func test_convertToGrayScale_producesMonochromeImageOfSameSize() {
        let gray = solidImage(.red).convertToGrayScale()
        XCTAssertEqual(gray.cgImage?.colorSpace?.model, .monochrome)
        XCTAssertEqual(gray.size, CGSize(width: 40, height: 20))
    }

    // MARK: - image(with:)

    func test_imageWithColor_tintsEveryPixel() {
        let tinted = solidImage(.white).image(with: .red)
        XCTAssertEqual(tinted?.size, CGSize(width: 40, height: 20))
        assertColor(tinted?.averageColor(), isCloseTo: (r: 1, g: 0, b: 0))
    }

    // MARK: - asBase64String

    func test_asBase64String_decodesBackToAnImage() {
        guard
            let base64 = solidImage(.blue).asBase64String,
            let data = Data(base64Encoded: base64)
        else { return XCTFail("Expected base64 round-trip data") }

        let decoded = UIImage(data: data)
        XCTAssertEqual(decoded?.cgImage?.width, 40)
        XCTAssertEqual(decoded?.cgImage?.height, 20)
    }

    // MARK: - averageColor(algorithm:)

    func test_averageColor_simple_onSolidColor() {
        assertColor(solidImage(.red).averageColor(), isCloseTo: (r: 1, g: 0, b: 0))
    }

    func test_averageColor_squareRoot_onSolidColor() {
        assertColor(solidImage(.red).averageColor(algorithm: .squareRoot), isCloseTo: (r: 1, g: 0, b: 0))
    }

    func test_averageColor_ofHalfRedHalfBlue_isPurple() {
        let size = CGSize(width: 40, height: 20)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let image = UIGraphicsImageRenderer(size: size, format: format).image { context in
            UIColor.red.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 20, height: 20))
            UIColor.blue.setFill()
            context.fill(CGRect(x: 20, y: 0, width: 20, height: 20))
        }
        assertColor(image.averageColor(), isCloseTo: (r: 0.5, g: 0, b: 0.5), accuracy: 0.06)
    }
}
