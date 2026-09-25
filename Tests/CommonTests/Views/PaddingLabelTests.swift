//
//  PaddingLabelTests.swift
//

import UIKit
import XCTest
@testable import Common

@MainActor
final class PaddingLabelTests: XCTestCase {

    func test_intrinsicContentSize_includesPaddingOnBothAxes() {
        let font = UIFont.systemFont(ofSize: 14)
        let text = "Tag"

        let plain = UILabel()
        plain.font = font
        plain.text = text
        let base = plain.intrinsicContentSize

        let padded = PaddingLabel(padding: .init(top: 3, left: 5, bottom: 7, right: 11))
        padded.font = font
        padded.text = text
        let size = padded.intrinsicContentSize

        XCTAssertEqual(size.width, base.width + 5 + 11, accuracy: 0.5)
        XCTAssertEqual(size.height, base.height + 3 + 7, accuracy: 0.5)
    }

    func test_zeroPadding_matchesPlainLabelIntrinsicSize() {
        let font = UIFont.systemFont(ofSize: 17)
        let text = "Hello"

        let plain = UILabel()
        plain.font = font
        plain.text = text

        let padded = PaddingLabel()
        padded.font = font
        padded.text = text

        XCTAssertEqual(padded.intrinsicContentSize.width, plain.intrinsicContentSize.width, accuracy: 0.5)
        XCTAssertEqual(padded.intrinsicContentSize.height, plain.intrinsicContentSize.height, accuracy: 0.5)
    }

    /// A proposal narrower than the combined horizontal padding must never
    /// produce a negative-size rect for `UILabel` to measure — that collapses
    /// the whole measurement to zero height and the text silently disappears.
    func test_proposalSmallerThanPadding_neverCollapsesMeasurement() {
        let padding = UIEdgeInsets(top: 6, left: 40, bottom: 6, right: 40)
        let label = PaddingLabel(padding: padding)
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14)
        label.text = String(repeating: "word ", count: 40)
        let proposal = CGSize(width: 60, height: 20) // narrower than left + right padding

        let fitted = label.sizeThatFits(proposal)
        let rect = label.textRect(forBounds: CGRect(origin: .zero, size: proposal), limitedToNumberOfLines: 0)

        // UILabel's own zero-width answer is one line of text (height ~17), so a
        // clamped measurement must exceed the bare padding box — the pre-fix
        // negative-width rect collapsed the text contribution to exactly zero.
        let verticalPaddingBox = padding.top + padding.bottom
        XCTAssertGreaterThan(fitted.height, verticalPaddingBox, "text must still occupy vertical space, not collapse to the padding box")
        XCTAssertGreaterThan(rect.height, verticalPaddingBox, "textRect must exceed the bare padding box")
        XCTAssertGreaterThanOrEqual(rect.width, padding.left + padding.right, "the returned rect must be at least the padding box")
    }

    /// The clamp must cover BOTH axes: a proposal shorter than the vertical
    /// padding hands `UILabel` a negative-height rect without it.
    func test_proposalShorterThanVerticalPadding_neverCollapsesMeasurement() {
        let label = PaddingLabel(padding: .init(top: 30, left: 6, bottom: 30, right: 6))
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14)
        label.text = String(repeating: "word ", count: 10)

        let rect = label.textRect(forBounds: CGRect(x: 0, y: 0, width: 200, height: 20), limitedToNumberOfLines: 0)

        // With a positive width and clamped-to-zero height, UILabel contributes
        // zero text height — the defined floor is exactly the padding box (the
        // pre-clamp code handed UILabel a negative-height rect instead).
        XCTAssertGreaterThanOrEqual(rect.height, 60, "the returned rect must be at least the vertical padding box (30 + 30)")
        XCTAssertGreaterThanOrEqual(rect.width, 12, "the returned rect must be at least the horizontal padding box")
    }

    /// `drawText(in:)` must actually shift the glyphs by the padding — the
    /// measurement overrides alone reserve the space, but deleting the drawText
    /// override draws text centered in the full bounds, ignoring asymmetric
    /// insets at render time.
    func test_drawText_keepsGlyphsOutOfThePaddingBand() {
        let padding = UIEdgeInsets(top: 40, left: 8, bottom: 0, right: 8)
        let label = PaddingLabel(padding: padding)
        label.text = "XXXXXXXX"
        label.font = .systemFont(ofSize: 20, weight: .black)
        label.textColor = .black
        label.backgroundColor = .white

        let size = label.intrinsicContentSize
        label.frame = CGRect(origin: .zero, size: size)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1 // point == pixel, so crop rects need no scale math
        let rendered = UIGraphicsImageRenderer(size: size, format: format).image { context in
            label.layer.render(in: context.cgContext)
        }

        // Top padding band (minus a hairline margin) must be glyph-free white;
        // the text region below it must contain ink.
        let band = CGRect(x: 0, y: 0, width: size.width, height: padding.top - 4)
        let textRegion = CGRect(x: 0, y: padding.top, width: size.width, height: size.height - padding.top)
        XCTAssertGreaterThan(averageBrightness(of: rendered, in: band), 0.95,
                             "glyphs leaked into the top padding band — drawText is not applying the insets")
        XCTAssertLessThan(averageBrightness(of: rendered, in: textRegion), 0.85,
                          "the text region should contain glyphs")
    }

    /// Average brightness (0 black … 1 white) of `rect` within `image`.
    private func averageBrightness(of image: UIImage, in rect: CGRect) -> CGFloat {
        guard let cropped = image.cropped(to: rect), let average = cropped.averageColor() else {
            XCTFail("could not sample \(rect)")
            return -1
        }
        var white: CGFloat = 0
        average.getWhite(&white, alpha: nil)
        return white
    }

    /// Auto Layout's first baseline includes the top padding: aligning a padded label to a plain one
    /// by first baseline lines up their text, which puts the padded label's frame `padding.top` higher.
    func test_firstBaseline_includesTopPadding() {
        let font = UIFont.systemFont(ofSize: 17)
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
        let plain = UILabel()
        plain.font = font
        plain.text = "Baseline"
        let padded = PaddingLabel(padding: .init(top: 20, left: 0, bottom: 0, right: 0))
        padded.font = font
        padded.text = "Baseline"
        [plain, padded].forEach { $0.translatesAutoresizingMaskIntoConstraints = false; container.addSubview($0) }
        NSLayoutConstraint.activate([
            plain.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            padded.leadingAnchor.constraint(equalTo: plain.trailingAnchor, constant: 8),
            plain.topAnchor.constraint(equalTo: container.topAnchor, constant: 100),
            padded.firstBaselineAnchor.constraint(equalTo: plain.firstBaselineAnchor)
        ])
        container.layoutIfNeeded()

        XCTAssertEqual(plain.frame.minY - padded.frame.minY, 20, accuracy: 0.5,
                       "the padded label's first baseline must sit `padding.top` below its top edge")
    }

    /// The padding is physical: `left` stays on the left in a right-to-left layout instead of being
    /// mirrored into a leading inset. Width is the intrinsic width, so the glyphs fill the text rect
    /// whatever the alignment.
    func test_padding_isNotMirroredInRightToLeftLayout() {
        for attribute in [UISemanticContentAttribute.forceLeftToRight, .forceRightToLeft] {
            let padding = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)
            let label = PaddingLabel(padding: padding)
            label.semanticContentAttribute = attribute
            label.text = "XXXXXXXX"
            label.font = .systemFont(ofSize: 20, weight: .black)
            label.textColor = .black
            label.backgroundColor = .white

            let size = label.intrinsicContentSize
            label.frame = CGRect(origin: .zero, size: size)
            let format = UIGraphicsImageRendererFormat()
            format.scale = 1 // point == pixel, so crop rects need no scale math
            let rendered = UIGraphicsImageRenderer(size: size, format: format).image { context in
                label.layer.render(in: context.cgContext)
            }

            let leftBand = CGRect(x: 0, y: 0, width: padding.left - 4, height: size.height)
            let rightBand = CGRect(x: size.width - 36, y: 0, width: 36, height: size.height)
            XCTAssertGreaterThan(averageBrightness(of: rendered, in: leftBand), 0.95,
                                 "the left padding must stay glyph-free (attribute \(attribute.rawValue))")
            XCTAssertLessThan(averageBrightness(of: rendered, in: rightBand), 0.85,
                              "the glyphs must reach the unpadded right edge (attribute \(attribute.rawValue))")
        }
    }

    /// Horizontal padding must narrow the wrapping width, so the same long text
    /// wraps into more lines and the text rect grows taller. This is the
    /// behavior the `textRect(forBounds:...)` override exists to provide.
    func test_horizontalPadding_forcesEarlierWrap_increasingHeight() {
        let font = UIFont.systemFont(ofSize: 14)
        let text = String(repeating: "word ", count: 40)
        let bounds = CGRect(x: 0, y: 0, width: 140, height: 2000)

        let noPad = PaddingLabel(padding: .zero)
        noPad.numberOfLines = 0
        noPad.font = font
        noPad.text = text

        let withPad = PaddingLabel(padding: .init(horizontal: 50))
        withPad.numberOfLines = 0
        withPad.font = font
        withPad.text = text

        let heightNoPad = noPad.textRect(forBounds: bounds, limitedToNumberOfLines: 0).height
        let heightWithPad = withPad.textRect(forBounds: bounds, limitedToNumberOfLines: 0).height

        XCTAssertGreaterThan(
            heightWithPad, heightNoPad,
            "horizontal padding should narrow the wrap width and increase the text-rect height"
        )
    }
}
