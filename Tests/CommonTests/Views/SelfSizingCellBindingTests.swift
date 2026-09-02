//
//  SelfSizingCellBindingTests.swift
//

import UIKit
import XCTest
@testable import Common

/// Regression for the consumer-app finding: self-sizing cells are measured right after
/// `cellForItemAt` configures them, before any update or layout pass. Content bound in
/// `updateContent()` must therefore already be present when `viewModel` is assigned,
/// otherwise the cell is measured against empty labels and clips its content.
@MainActor
final class SelfSizingCellBindingTests: XCTestCase {

    private final class TextItem: ViewModel {
        let text: String
        init(_ text: String) { self.text = text }
    }

    private final class TextCell: BaseViewModelableCell<TextItem> {
        static let identifier = String(describing: TextCell.self)
        private lazy var label = UILabel().numberOfLines(0).font(.systemFont(ofSize: 17))

        @UIViewBuilder override var mainView: UIView {
            VStack(margins: .init(all: 8)) { label }
        }

        override func updateContent() {
            label.text(viewModel?.text ?? "")
        }

        override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
            let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
            attributes.frame.size = contentView.systemLayoutSizeFitting(
                CGSize(width: layoutAttributes.size.width, height: UIView.layoutFittingCompressedSize.height),
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            )
            return attributes
        }
    }

    private final class Source: NSObject, UICollectionViewDataSource {
        let items: [TextItem]
        init(items: [TextItem]) { self.items = items }
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { items.count }
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextCell.identifier, for: indexPath) as! TextCell
            cell.viewModel = items[indexPath.item]   // the only binding call, as in a real data source
            return cell
        }
    }

    private var window: UIWindow!
    private var source: Source!

    override func setUp() {
        super.setUp()
        window = UIWindow(frame: .init(x: .zero, y: .zero, width: 320, height: 640))
        window.isHidden = false
    }

    override func tearDown() {
        ObservationMode.override = nil
        window.isHidden = true
        window = nil
        source = nil
        super.tearDown()
    }

    private func measuredHeights(mode: ObservationMode) -> [CGFloat] {
        ObservationMode.override = mode
        let layout = UICollectionViewFlowLayout()
        // A concrete estimate (as a consumer's onSizeForItem would return) with self-sizing on:
        // the cell's preferredLayoutAttributesFitting decides the final height.
        layout.estimatedItemSize = CGSize(width: 320, height: 44)
        let collectionView = UICollectionView(frame: window.bounds, collectionViewLayout: layout)
        collectionView.register(TextCell.self, forCellWithReuseIdentifier: TextCell.identifier)
        source = Source(items: [
            TextItem("one line"),
            TextItem(String(repeating: "a long line of text that wraps several times ", count: 6))
        ])
        collectionView.dataSource = source
        window.addSubview(collectionView)
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        return (0..<2).compactMap { collectionView.cellForItem(at: IndexPath(item: $0, section: 0))?.frame.height }
    }

    private func assertWrappedRowIsTaller(_ heights: [CGFloat], file: StaticString = #filePath, line: UInt = #line) {
        guard heights.count == 2 else { return XCTFail("expected two visible cells, got \(heights)", file: file, line: line) }
        XCTAssertGreaterThan(heights[1], heights[0] * 2, "the wrapped row must be measured against its text, not an empty label", file: file, line: line)
    }

    func test_manualMode_selfSizingCellIsMeasuredWithBoundContent() {
        assertWrappedRowIsTaller(measuredHeights(mode: .manual))
    }

    func test_unavailableMode_selfSizingCellIsMeasuredWithBoundContent() {
        assertWrappedRowIsTaller(measuredHeights(mode: .unavailable))
    }

    func test_nativeMode_selfSizingCellIsMeasuredWithBoundContent() throws {
        guard #available(iOS 26.0, *) else { throw XCTSkip("native path needs iOS 26") }
        assertWrappedRowIsTaller(measuredHeights(mode: .native))
    }
}
