//
//  SelfSizingInvalidationTests.swift
//

import Observation
import UIKit
import XCTest
@testable import Common

@available(iOS 17.0, *)
@Observable @MainActor
private final class ExpandableItem: ViewModel {
    var isExpanded = false
    let text = String(repeating: "a long line of text that wraps several times ", count: 6)
}

/// Pins UIKit's behavior for a self-sizing row whose `updateContent()` changes its height on an observed change: with
/// the list's default `selfSizingInvalidation` the row keeps its height, and with `.enabledIncludingConstraints` the
/// list measures it again. A later UIKit that changes either fails this test, the cue to update guide §5's self-sizing
/// rule.
@available(iOS 17.0, *)
@MainActor
final class SelfSizingInvalidationTests: XCTestCase {

    private final class ExpandableCell: BaseViewModelableCell<ExpandableItem> {
        static let identifier = String(describing: ExpandableCell.self)
        private lazy var label = UILabel().font(.systemFont(ofSize: 17))

        @UIViewBuilder override var mainView: UIView {
            VStack(margins: .init(all: 8)) { label }
        }

        override func updateContent() {
            label.text(viewModel?.text)
            label.numberOfLines(viewModel?.isExpanded == true ? .zero : 1)
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
        let item = ExpandableItem()
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { 1 }
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ExpandableCell.identifier, for: indexPath) as! ExpandableCell
            cell.viewModel = item
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

    private func settle() {
        for _ in 0..<3 {
            window.layoutIfNeeded()
            RunLoop.main.run(until: Date().addingTimeInterval(0.05))
        }
    }

    /// The row's height before and after its item expands, and the height its expanded content needs.
    private func rowHeights(mode: ObservationMode, invalidation: UICollectionView.SelfSizingInvalidation?) -> (collapsed: CGFloat, expanded: CGFloat, needed: CGFloat) {
        ObservationMode.override = mode
        let layout = UICollectionViewFlowLayout()
        // A concrete estimate, as a view model's onSizeForItem returns, with self-sizing on.
        layout.estimatedItemSize = CGSize(width: 320, height: 44)
        let list = UICollectionView(frame: window.bounds, collectionViewLayout: layout)
        if let invalidation { list.selfSizingInvalidation = invalidation }
        list.register(ExpandableCell.self, forCellWithReuseIdentifier: ExpandableCell.identifier)
        source = Source()
        list.dataSource = source
        window.addSubview(list)
        list.reloadData()
        settle()
        let row = IndexPath(item: .zero, section: .zero)
        let collapsed = list.cellForItem(at: row)?.frame.height ?? -1

        source.item.isExpanded = true
        settle()

        let cell = list.cellForItem(at: row)
        let needed = cell?.contentView.systemLayoutSizeFitting(
            CGSize(width: list.bounds.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height ?? -1
        return (collapsed, cell?.frame.height ?? -1, needed)
    }

    private func assertKeepsItsHeight(mode: ObservationMode, file: StaticString = #filePath, line: UInt = #line) {
        let list = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        XCTAssertEqual(list.selfSizingInvalidation, .enabled, "UIKit's default", file: file, line: line)
        let heights = rowHeights(mode: mode, invalidation: nil)
        XCTAssertGreaterThan(heights.needed, heights.collapsed * 2, "the expanded content needs more room", file: file, line: line)
        XCTAssertEqual(heights.expanded, heights.collapsed, accuracy: 0.5, "the row isn't measured again", file: file, line: line)
    }

    private func assertIsMeasuredAgain(mode: ObservationMode, file: StaticString = #filePath, line: UInt = #line) {
        let heights = rowHeights(mode: mode, invalidation: .enabledIncludingConstraints)
        XCTAssertGreaterThan(heights.expanded, heights.collapsed * 2, file: file, line: line)
        XCTAssertEqual(heights.expanded, heights.needed, accuracy: 1, "the row takes the height its content needs", file: file, line: line)
    }

    func test_manualMode_defaultInvalidation_aRowThatGrowsKeepsItsHeight() {
        assertKeepsItsHeight(mode: .manual)
    }

    func test_manualMode_enabledIncludingConstraints_aRowThatGrowsIsMeasuredAgain() {
        assertIsMeasuredAgain(mode: .manual)
    }

    func test_nativeMode_defaultInvalidation_aRowThatGrowsKeepsItsHeight() throws {
        guard #available(iOS 26.0, *) else { throw XCTSkip("native path needs iOS 26") }
        assertKeepsItsHeight(mode: .native)
    }

    func test_nativeMode_enabledIncludingConstraints_aRowThatGrowsIsMeasuredAgain() throws {
        guard #available(iOS 26.0, *) else { throw XCTSkip("native path needs iOS 26") }
        assertIsMeasuredAgain(mode: .native)
    }
}
