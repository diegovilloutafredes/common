//
//  UIImageProcessingTests.swift
//

import UIKit
import XCTest
@testable import Common

/// Pins the behavior of the image-processing extensions using small in-memory
/// fixtures (scale 1, so points == pixels). Geometry alone is not enough:
/// two-tone fixtures assert pixel CONTENT, so direction flips and dropped
/// draw calls can't hide behind a correctly-sized blank output.
@MainActor
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

    /// Left half red, right half blue — the asymmetric fixture that makes
    /// rotation direction and orientation flips observable.
    private func twoToneImage(width: CGFloat = 40, height: CGFloat = 20) -> UIImage {
        let size = CGSize(width: width, height: height)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            UIColor.red.setFill()
            context.fill(CGRect(x: 0, y: 0, width: width / 2, height: height))
            UIColor.blue.setFill()
            context.fill(CGRect(x: width / 2, y: 0, width: width / 2, height: height))
        }
    }

    private func averageColorOfRegion(_ image: UIImage?, _ rect: CGRect) -> UIColor? {
        image?.cropped(to: rect)?.averageColor()
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

    /// Content, not just geometry: a negated angle, a dropped translate, or a
    /// deleted draw(in:) all produce a correctly-sized wrong image.
    func test_rotate_quarterTurn_movesLeftHalfToTop() {
        let rotated = twoToneImage().rotate(radians: .pi / 2) // 20x40 after rotation

        // +π/2 in UIKit's y-down coordinates is a clockwise turn: the red LEFT
        // half must land in the TOP half of the rotated image.
        assertColor(averageColorOfRegion(rotated, .init(x: 0, y: 0, width: 20, height: 20)),
                    isCloseTo: (r: 1, g: 0, b: 0))
        assertColor(averageColorOfRegion(rotated, .init(x: 0, y: 20, width: 20, height: 20)),
                    isCloseTo: (r: 0, g: 0, b: 1))
    }

    func test_rotate_halfTurn_swapsHalves() {
        let rotated = twoToneImage().rotate(radians: .pi)

        assertColor(averageColorOfRegion(rotated, .init(x: 0, y: 0, width: 20, height: 20)),
                    isCloseTo: (r: 0, g: 0, b: 1), accuracy: 0.06)
        assertColor(averageColorOfRegion(rotated, .init(x: 20, y: 0, width: 20, height: 20)),
                    isCloseTo: (r: 1, g: 0, b: 0), accuracy: 0.06)
    }

    /// Scale must propagate through the redraw — every other fixture is scale 1,
    /// so a hardcoded scale would survive the rest of the file.
    func test_rotate_preservesImageScale() {
        let size = CGSize(width: 40, height: 20)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 3
        let image = UIGraphicsImageRenderer(size: size, format: format).image { context in
            UIColor.red.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }

        let rotated = image.rotate(radians: .pi / 2)

        XCTAssertEqual(rotated?.scale, 3)
        XCTAssertEqual(rotated?.cgImage?.width, 60, "pixel width must be 3x the 20pt rotated width")
        XCTAssertEqual(rotated?.cgImage?.height, 120)
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

    /// The transform math itself: the fixed image's pixels must match what the
    /// oriented image DISPLAYED as. A negated rotation or swapped left/right
    /// branch still yields .up orientation at the right size.
    func test_fixOrientation_leftOrientedImage_preservesDisplayedContent() {
        guard let cgImage = twoToneImage().cgImage
        else { return XCTFail("Expected a cgImage") }
        // .left: raw pixels are shown rotated 90° counterclockwise — the raw
        // red LEFT half displays in the BOTTOM half (20x40 displayed).
        let oriented = UIImage(cgImage: cgImage, scale: 1, orientation: .left)

        let fixed = oriented.fixOrientation()

        assertColor(averageColorOfRegion(fixed, .init(x: 0, y: 20, width: 20, height: 20)),
                    isCloseTo: (r: 1, g: 0, b: 0))
        assertColor(averageColorOfRegion(fixed, .init(x: 0, y: 0, width: 20, height: 20)),
                    isCloseTo: (r: 0, g: 0, b: 1))
    }

    // MARK: - convertToGrayScale()

    func test_convertToGrayScale_producesMonochromeImageOfSameSize() {
        let gray = solidImage(.red).convertToGrayScale()
        XCTAssertEqual(gray.cgImage?.colorSpace?.model, .monochrome)
        XCTAssertEqual(gray.size, CGSize(width: 40, height: 20))
        // Colorspace + size are context properties — only a brightness check
        // proves the source was actually DRAWN into it (a deleted draw yields
        // a correctly-sized black monochrome image).
        guard let average = gray.averageColor() else { return XCTFail("Expected an average color") }
        var white: CGFloat = 0
        average.getWhite(&white, alpha: nil)
        XCTAssertGreaterThan(white, 0.15, "grayscale of solid red must not be black — was the image drawn?")
        XCTAssertLessThan(white, 0.75, "grayscale of solid red must be mid-range, not washed out")
    }

    // MARK: - image(with:)

    func test_imageWithColor_tintsEveryPixel() {
        let tinted = solidImage(.white).image(with: .red)
        XCTAssertEqual(tinted?.size, CGSize(width: 40, height: 20))
        assertColor(tinted?.averageColor(), isCloseTo: (r: 1, g: 0, b: 0))
    }

    /// A fully opaque fixture can't observe the mask semantics — deleting the
    /// `clip(to:mask:)` would fill the whole rect and still pass the test above.
    /// A half-transparent fixture is what proves the tint respects the alpha mask.
    func test_imageWithColor_respectsAlphaMask() throws {
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = false
        format.scale = 1
        let fixture = UIGraphicsImageRenderer(size: .init(width: 40, height: 20), format: format)
            .image { _ in
                UIColor.white.setFill()
                UIRectFill(CGRect(x: 0, y: 0, width: 20, height: 20)) // left half opaque, right half transparent
            }

        let cg = try XCTUnwrap(fixture.image(with: .red)?.cgImage)

        // Downsample to 2x1 with nearest-neighbor: pixel 0 samples the opaque
        // half, pixel 1 the transparent half.
        var pixels = [UInt8](repeating: 0, count: 8)
        let context = try XCTUnwrap(CGContext(
            data: &pixels, width: 2, height: 1, bitsPerComponent: 8, bytesPerRow: 8,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ))
        context.interpolationQuality = .none
        context.draw(cg, in: CGRect(x: 0, y: 0, width: 2, height: 1))

        XCTAssertGreaterThan(pixels[0], 200, "opaque half must be tinted red")
        XCTAssertGreaterThan(pixels[3], 200, "opaque half must stay opaque")
        XCTAssertEqual(pixels[7], 0, "transparent half must stay transparent — a dropped clip mask fills the whole rect")
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
        // The documented contract is JPEG (quality 1.0) — backend consumers may
        // depend on the format. 0xFFD8 is the JPEG SOI marker.
        XCTAssertEqual(data.prefix(2), Data([0xFF, 0xD8]), "asBase64String must encode as JPEG")
    }

    // MARK: - averageColor(algorithm:)

    func test_averageColor_simple_onSolidColor() {
        assertColor(solidImage(.red).averageColor(), isCloseTo: (r: 1, g: 0, b: 0))
    }

    func test_averageColor_squareRoot_onSolidColor() {
        assertColor(solidImage(.red).averageColor(algorithm: .squareRoot), isCloseTo: (r: 1, g: 0, b: 0))
    }

    /// On a solid color the two algorithms are mathematically identical
    /// (sqrt(255²) == 255) — only a mixed image separates the branches:
    /// squareRoot gives sqrt((255² + 0)/2)/255 ≈ 0.707 where simple gives 0.5.
    func test_averageColor_squareRoot_differsFromSimple_onMixedImage() {
        let size = CGSize(width: 40, height: 20)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let image = UIGraphicsImageRenderer(size: size, format: format).image { context in
            UIColor.red.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 20, height: 20))
            UIColor.blue.setFill()
            context.fill(CGRect(x: 20, y: 0, width: 20, height: 20))
        }
        assertColor(image.averageColor(algorithm: .squareRoot),
                    isCloseTo: (r: 0.707, g: 0, b: 0.707), accuracy: 0.06)
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
