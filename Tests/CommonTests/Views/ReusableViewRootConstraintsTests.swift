//
//  ReusableViewRootConstraintsTests.swift
//

import XCTest
@testable import Common

/// Cells and reusable views install `mainView` the way `BaseView` does: the constraints its root
/// declares are the ones applied, and only a root that declares none is pinned edge to edge.
@MainActor
final class ReusableViewRootConstraintsTests: XCTestCase {

    private enum Declaration { case insetBy8, nothing, fullSnap }

    private final class Cell: BaseCell {
        let root: UIView
        init(frame: CGRect, root: UIView) {
            self.root = root
            super.init(frame: frame)
        }
        @available(*, unavailable)
        required init(coder: NSCoder) { fatalError("NSCoder is not supported") }
        override var mainView: UIView { root }
    }

    private final class ReusableView: BaseReusableView {
        let root: UIView
        init(frame: CGRect, root: UIView) {
            self.root = root
            super.init(frame: frame)
        }
        @available(*, unavailable)
        required init(coder: NSCoder) { fatalError("NSCoder is not supported") }
        override var mainView: UIView { root }
    }

    private let frame = CGRect(x: 0, y: 0, width: 200, height: 100)

    private func root(declaring declaration: Declaration) -> UIView {
        let root = UIView()
        switch declaration {
        case .insetBy8: return root.setConstraints { $0.snap(to: $1, insets: .init(all: 8)) }
        case .nothing: return root
        case .fullSnap: return root.setConstraints { $0.snap(to: $1) }
        }
    }

    private func cellRootFrame(declaring declaration: Declaration) -> CGRect {
        let cell = Cell(frame: frame, root: root(declaring: declaration))
        cell.layoutIfNeeded()
        return cell.root.frame
    }

    private func reusableRootFrame(declaring declaration: Declaration) -> CGRect {
        let view = ReusableView(frame: frame, root: root(declaring: declaration))
        view.layoutIfNeeded()
        return view.root.frame
    }

    // MARK: - BaseCell

    func test_cell_rootDeclaringAnInset_sitsInsideTheContentView() {
        XCTAssertEqual(cellRootFrame(declaring: .insetBy8), CGRect(x: 8, y: 8, width: 184, height: 84))
    }

    func test_cell_rootDeclaringNothing_isPinnedEdgeToEdge() {
        XCTAssertEqual(cellRootFrame(declaring: .nothing), CGRect(x: 0, y: 0, width: 200, height: 100))
    }

    func test_cell_rootDeclaringTheConventionalSnap_isPinnedEdgeToEdge() {
        XCTAssertEqual(cellRootFrame(declaring: .fullSnap), CGRect(x: 0, y: 0, width: 200, height: 100))
    }

    // MARK: - BaseReusableView

    func test_reusableView_rootDeclaringAnInset_sitsInsideTheView() {
        XCTAssertEqual(reusableRootFrame(declaring: .insetBy8), CGRect(x: 8, y: 8, width: 184, height: 84))
    }

    func test_reusableView_rootDeclaringNothing_isPinnedEdgeToEdge() {
        XCTAssertEqual(reusableRootFrame(declaring: .nothing), CGRect(x: 0, y: 0, width: 200, height: 100))
    }

    func test_reusableView_rootDeclaringTheConventionalSnap_isPinnedEdgeToEdge() {
        XCTAssertEqual(reusableRootFrame(declaring: .fullSnap), CGRect(x: 0, y: 0, width: 200, height: 100))
    }
}
