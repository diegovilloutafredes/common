//
//  PillUILabelTests.swift
//

import UIKit
import XCTest
@testable import Common

@MainActor
final class PillUILabelTests: XCTestCase {

    private let sampleText = "A reasonably long badge text that wraps"

    /// PaddingLabel is the proven inset mechanism (measurement AND drawing honor
    /// the insets). PillUILabel's padding must behave identically — parity with
    /// an equivalently configured PaddingLabel is the contract.
    private func makeReferenceLabel() -> PaddingLabel {
        PaddingLabel(padding: .init(horizontal: 8, vertical: 8))
            .font(.systemFont(ofSize: 16))
            .numberOfLines()
            .textAlignment(.center)
    }

    private func makePill() -> PillUILabel {
        PillUILabel()
    }

    // MARK: - Padding integrity (L1)

    func test_textRect_underWidthCompression_matchesPaddingLabelMechanism() {
        let pill = makePill().text(sampleText)
        let reference = makeReferenceLabel().text(sampleText)
        let narrowBounds = CGRect(x: 0, y: 0, width: 120, height: 1000)

        let pillRect = pill.textRect(forBounds: narrowBounds, limitedToNumberOfLines: 0)
        let referenceRect = reference.textRect(forBounds: narrowBounds, limitedToNumberOfLines: 0)

        XCTAssertEqual(pillRect, referenceRect,
                       "compressed/wrapped text must lay out against the inset width — padding cannot live only in intrinsicContentSize")
    }

    func test_multiLineWrap_reservesVerticalPadding() {
        let pill = makePill().text(sampleText)
        let narrowBounds = CGRect(x: 0, y: 0, width: 120, height: 1000)
        let unpadded = UILabel(sampleText).font(.systemFont(ofSize: 16)).numberOfLines()

        let pillRect = pill.textRect(forBounds: narrowBounds, limitedToNumberOfLines: 0)
        let unpaddedRect = unpadded.textRect(forBounds: narrowBounds.insetBy(dx: 8, dy: 8), limitedToNumberOfLines: 0)

        XCTAssertEqual(pillRect.height, unpaddedRect.height + 16, accuracy: 0.5,
                       "wrapped text height must include the vertical padding")
    }

    func test_singleLineIntrinsicSize_isTextSizePlusPadding() {
        let pill = makePill().text("BADGE")
        let plain = UILabel("BADGE").font(.systemFont(ofSize: 16))

        let intrinsic = pill.intrinsicContentSize
        let plainIntrinsic = plain.intrinsicContentSize

        XCTAssertEqual(intrinsic.width, plainIntrinsic.width + 16, accuracy: 0.5,
                       "existing single-line behavior preserved: text width + horizontal padding")
        XCTAssertEqual(intrinsic.height, plainIntrinsic.height + 16, accuracy: 0.5,
                       "existing single-line behavior preserved: text height + vertical padding")
    }
}
