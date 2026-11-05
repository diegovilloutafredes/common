//
//  ContentTrackingTests.swift
//

import Observation
import UIKit
import XCTest
@testable import Common

/// How the bases track `updateContent()` in the manual mode (iOS 17–18), counted in hook runs: which registration may
/// schedule a pass, whether a nested render joins its parent's tracking, and when a view-model-able view first binds.
/// The manual mode is forced with `ObservationMode.override`; on an iOS 18 simulator it is the real one.
@available(iOS 17.0, *)
@MainActor
final class ContentTrackingTests: XCTestCase {

    /// Renders whichever model it currently points at.
    private final class SwitchView: BaseView {
        var model: ObservedCounter
        private(set) var runs: Int = .zero

        init(model: ObservedCounter) {
            self.model = model
            super.init()
        }

        override func updateContent() {
            runs += 1
            _ = model.value
        }
    }

    private final class ChildView: BaseViewModelableView<ObservedCounter> {
        private(set) var runs: Int = .zero
        private(set) var rendered = -1

        override func updateContent() {
            runs += 1
            rendered = viewModel.value
        }
    }

    /// The common composition shape: the parent's hook binds its child's view model.
    private final class ParentView: BaseView {
        let parentModel: ObservedCounter
        let childModel: ObservedCounter
        let child: ChildView
        private(set) var runs: Int = .zero

        init(parentModel: ObservedCounter, childModel: ObservedCounter) {
            self.parentModel = parentModel
            self.childModel = childModel
            child = ChildView(viewModel: childModel)
            super.init()
        }

        @UIViewBuilder override var mainView: UIView { VStack { child } }

        override func updateContent() {
            runs += 1
            _ = parentModel.value
            child.viewModel = childModel
        }
    }

    private final class GreetingView: BaseViewModelableView<String> {
        let label = UILabel()

        @UIViewBuilder override var mainView: UIView { VStack(alignment: .leading) { label } }

        override func updateContent() { label.text = viewModel }
    }

    private final class CounterCell: BaseViewModelableCell<ObservedCounter> {
        private(set) var runs: Int = .zero

        override func updateContent() {
            runs += 1
            _ = viewModel?.value
        }
    }

    /// A parent whose hook binds a cell, as a hook that forces a list's layout does: cells bind synchronously, so the
    /// cell renders nested in the parent's render.
    private final class CellHostView: BaseView {
        let cell = CounterCell(frame: .init(x: .zero, y: .zero, width: 100, height: 44))
        let cellModel: ObservedCounter
        private(set) var runs: Int = .zero

        init(cellModel: ObservedCounter) {
            self.cellModel = cellModel
            super.init()
        }

        override func updateContent() {
            runs += 1
            cell.viewModel = cellModel
        }
    }

    /// Adds itself to `host` while it initializes, as the snackbar adds itself to its window.
    private final class SelfInstallingView: BaseViewModelableView<String> {
        static weak var host: UIView?
        let label = UILabel()

        @UIViewBuilder override var mainView: UIView { VStack(alignment: .leading) { label } }

        override func setupView() {
            super.setupView()
            Self.host?.addSubview(self)
        }

        override func updateContent() { label.text = viewModel }
    }

    /// Creates a view-model-able view from its hook while flagged for another pass, and records how deep its own
    /// passes nested.
    private final class CreatingViewController: BaseViewController {
        private(set) var created: SelfInstallingView?
        private(set) var deepestPass: Int = .zero
        private var depth: Int = .zero

        override func updateContent() {
            super.updateContent()
            depth += 1
            defer { depth -= 1 }
            deepestPass = max(deepestPass, depth)
            if created.isNil {
                setNeedsContentUpdate()
                SelfInstallingView.host = view
                created = SelfInstallingView(viewModel: "made in the hook")
            }
        }
    }

    private var window: UIWindow!

    override func setUp() {
        super.setUp()
        window = UIWindow(frame: .init(x: .zero, y: .zero, width: 300, height: 300))
        window.isHidden = false
    }

    override func tearDown() {
        ObservationMode.override = nil
        SelfInstallingView.host = nil
        window.isHidden = true
        window = nil
        super.tearDown()
    }

    private func hosted<View: UIView>(_ view: View) -> View {
        view.frame = window.bounds
        window.addSubview(view)
        return view
    }

    private func detached<View: UIView>(_ view: View) -> View {
        view.frame = window.bounds
        return view
    }

    // MARK: - Only the latest run schedules

    /// The defect: a run couldn't cancel the registration of the run before it, so a model the view no longer read
    /// still re-rendered it.
    func test_manualMode_aModelTheViewStoppedReading_doesNotRenderIt() {
        ObservationMode.override = .manual
        let shown = ObservedCounter()
        let replaced = ObservedCounter()
        let view = detached(SwitchView(model: replaced))
        view.layoutIfNeeded()
        view.model = shown
        view.setNeedsContentUpdate()
        view.layoutIfNeeded()
        let runsBefore = view.runs

        replaced.value += 1
        let scheduled = view.layer.needsLayout()
        view.layoutIfNeeded()

        XCTAssertFalse(scheduled, "a change to a model the view stopped reading schedules nothing")
        XCTAssertEqual(view.runs, runsBefore)
    }

    func test_manualMode_aChangeToTheCurrentModel_rendersOnce() {
        ObservationMode.override = .manual
        let model = ObservedCounter()
        let view = detached(SwitchView(model: ObservedCounter()))
        view.layoutIfNeeded()
        view.model = model
        view.setNeedsContentUpdate()
        view.layoutIfNeeded()
        let runsBefore = view.runs

        model.value += 1
        view.layoutIfNeeded()

        XCTAssertEqual(view.runs, runsBefore + 1)
    }

    // MARK: - A new run replaces the previous registration

    /// The defect: every forced run left its registration on the model, so the next change fired all of them.
    func test_manualMode_afterAThousandForcedRenders_aChangeReachesTheViewOnce() {
        ObservationMode.override = .manual
        let model = ObservedCounter()
        let view = detached(SwitchView(model: model))
        view.layoutIfNeeded()
        for _ in 1...1_000 {
            view.setNeedsContentUpdate()
            view.layoutIfNeeded()
        }
        let callbacksBefore = view.contentTracking.callbacks
        let runsBefore = view.runs

        model.value += 1
        view.layoutIfNeeded()

        XCTAssertEqual(view.contentTracking.callbacks, callbacksBefore + 1, "one registration was left to fire")
        XCTAssertEqual(view.runs, runsBefore + 1)
    }

    /// A list reload binds each visible cell again, usually to the same model.
    func test_manualMode_aCellReboundToTheSameModel_holdsOneRegistration() {
        ObservationMode.override = .manual
        let model = ObservedCounter()
        let cell = CounterCell(frame: .init(x: .zero, y: .zero, width: 100, height: 44))
        for _ in 1...100 { cell.viewModel = model }
        let callbacksBefore = cell.contentTracking.callbacks

        model.value += 1

        XCTAssertEqual(cell.contentTracking.callbacks, callbacksBefore + 1)
    }

    /// A cell bound inside another render isn't revocable: its reads merge into the outer registration, and revoking
    /// it later would re-render the outer view for nothing.
    func test_manualMode_aCellBoundInsideAnotherRender_rebindingItLaterDoesNotRenderTheParent() {
        ObservationMode.override = .manual
        let cellModel = ObservedCounter()
        let parent = detached(CellHostView(cellModel: cellModel))
        parent.layoutIfNeeded()
        let parentRuns = parent.runs

        parent.cell.viewModel = cellModel
        parent.layoutIfNeeded()

        XCTAssertEqual(parent.runs, parentRuns)
    }

    // MARK: - A nested plain view renders in its own pass

    /// The defect: the child bound inside the parent's tracked render, so its reads joined the parent's registration
    /// and a change only the child reads re-rendered the parent too.
    func test_manualMode_aChildOnlyChange_rendersOnlyTheChild() {
        ObservationMode.override = .manual
        let parentModel = ObservedCounter()
        let childModel = ObservedCounter()
        let parent = hosted(ParentView(parentModel: parentModel, childModel: childModel))
        window.layoutIfNeeded()
        let parentRuns = parent.runs
        let childRuns = parent.child.runs

        childModel.value = 42
        window.layoutIfNeeded()

        XCTAssertEqual(parent.runs, parentRuns, "the parent doesn't track what its child reads")
        XCTAssertEqual(parent.child.runs, childRuns + 1)
        XCTAssertEqual(parent.child.rendered, 42)
    }

    func test_manualMode_aParentChange_rendersTheParentOnce_andTheChildKeepsItsModel() {
        ObservationMode.override = .manual
        let parentModel = ObservedCounter()
        let childModel = ObservedCounter()
        childModel.value = 7
        let parent = hosted(ParentView(parentModel: parentModel, childModel: childModel))
        window.layoutIfNeeded()
        let parentRuns = parent.runs

        parentModel.value += 1
        window.layoutIfNeeded()

        XCTAssertEqual(parent.runs, parentRuns + 1)
        XCTAssertTrue(parent.child.viewModel === childModel)
        XCTAssertEqual(parent.child.rendered, 7)
    }

    // MARK: - Binding at initialization

    /// The defect: `init(viewModel:)` stored the model without binding it, so a view measured before its first pass
    /// measured empty content.
    func test_manualMode_aViewMeasuredRightAfterInit_hasItsContent() {
        ObservationMode.override = .manual

        let view = GreetingView(viewModel: "A fairly long greeting that needs some width")

        XCTAssertEqual(view.label.text, "A fairly long greeting that needs some width")
        XCTAssertGreaterThan(view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).width, .zero)
    }

    func test_nativeMode_aViewMeasuredRightAfterInit_hasItsContent() throws {
        guard #available(iOS 26.0, *) else { throw XCTSkip("native path needs iOS 26") }
        ObservationMode.override = .native

        let view = GreetingView(viewModel: "A fairly long greeting that needs some width")

        XCTAssertEqual(view.label.text, "A fairly long greeting that needs some width")
        XCTAssertGreaterThan(view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).width, .zero)
    }

    func test_manualMode_aViewCreatedInsideAFlaggedControllersHook_doesNotRerunThatHook() {
        ObservationMode.override = .manual
        let vc = CreatingViewController()
        vc.loadViewIfNeeded()
        vc.view.frame = window.bounds

        vc.view.layoutIfNeeded()
        vc.view.layoutIfNeeded()

        XCTAssertEqual(vc.deepestPass, 1)
        XCTAssertEqual(vc.created?.label.text, "made in the hook")
    }

    func test_nativeMode_aViewCreatedInsideAFlaggedControllersHook_doesNotRerunThatHook() throws {
        guard #available(iOS 26.0, *) else { throw XCTSkip("native path needs iOS 26") }
        ObservationMode.override = .native
        let vc = CreatingViewController()
        window.rootViewController = vc

        vc.updatePropertiesIfNeeded()
        window.layoutIfNeeded()

        XCTAssertEqual(vc.deepestPass, 1)
        XCTAssertEqual(vc.created?.label.text, "made in the hook")
    }
}
