//
//  UIViewControllerAnimateContentChangeTests.swift
//

import Observation
import UIKit
import XCTest
@testable import Common

@available(iOS 17.0, *)
@Observable
private final class BarState {
    var isWide = false
}

/// `animateContentChange(_:options:changes:completion:)` on a controller whose hook sets a width constraint from an
/// observable flag, hosted in a window: the update pass that the change causes runs inside the animation, in both modes.
@available(iOS 17.0, *)
@MainActor
final class UIViewControllerAnimateContentChangeTests: XCTestCase {

    private enum Width {
        static let narrow: CGFloat = 80
        static let wide: CGFloat = 240
    }

    private final class BarViewController: BaseViewController {
        let state = BarState()
        private(set) var hookRuns: Int = .zero
        private(set) lazy var bar = UIView().setConstraints { $0.set(height: 24) }
        private lazy var barWidth = bar.widthAnchor.constraint(equalToConstant: Width.narrow)

        @UIViewBuilder override var mainView: UIView {
            VStack(alignment: .leading) { bar }   // .leading: the bar keeps its own width
                .setConstraints { $0.snapLeadTopTrail(to: $1) }
        }

        override func setupView() {
            super.setupView()
            barWidth.isActive = true
        }

        override func updateContent() {
            super.updateContent()
            hookRuns += 1
            barWidth.constant = state.isWide ? Width.wide : Width.narrow
        }
    }

    private var window: UIWindow?

    override func tearDown() {
        ObservationMode.override = nil
        window?.isHidden = true
        window = nil
        super.tearDown()
    }

    /// A controller in a window, laid out at the narrow width. The mode is set first: the controller reads it as it
    /// renders.
    private func makeHosted(mode: ObservationMode) -> BarViewController {
        ObservationMode.override = mode
        let vc = BarViewController()
        let window = UIWindow(frame: .init(x: .zero, y: .zero, width: 320, height: 480))
        window.rootViewController = vc
        window.isHidden = false
        self.window = window
        for _ in 0..<3 {
            window.layoutIfNeeded()
            RunLoop.main.run(until: Date().addingTimeInterval(0.05))
        }
        return vc
    }

    /// Waits for `completed`, then lets the run loop finish the animation's bookkeeping.
    private func waitForCompletion(_ completed: XCTestExpectation) {
        wait(for: [completed], timeout: 5)
        RunLoop.main.run(until: Date().addingTimeInterval(0.1))
    }

    private func assertAnimatesTheChange(mode: ObservationMode, file: StaticString = #filePath, line: UInt = #line) {
        let vc = makeHosted(mode: mode)
        XCTAssertEqual(vc.bar.bounds.width, Width.narrow, file: file, line: line)
        let runsBefore = vc.hookRuns
        var completions: Int = .zero
        let completed = expectation(description: "completion")

        vc.animateContentChange(0.3, changes: { vc.state.isWide.toggle() }, completion: { _ in
            completions += 1
            completed.fulfill()
        })

        XCTAssertNotNil(vc.bar.layer.animationKeys(), "the pass the change caused ran inside the animation", file: file, line: line)
        XCTAssertEqual(vc.hookRuns, runsBefore + 1, "the hook ran once for the change", file: file, line: line)
        waitForCompletion(completed)
        XCTAssertEqual(completions, 1, file: file, line: line)
        XCTAssertEqual(vc.bar.frame.width, Width.wide, accuracy: 0.5, file: file, line: line)
        XCTAssertEqual(vc.hookRuns, runsBefore + 1, "and not again", file: file, line: line)
    }

    private func assertAnEqualWriteCompletesWithoutAPass(mode: ObservationMode, file: StaticString = #filePath, line: UInt = #line) {
        let vc = makeHosted(mode: mode)
        let runsBefore = vc.hookRuns
        let current = vc.state.isWide
        var completions: Int = .zero
        let completed = expectation(description: "completion")

        vc.animateContentChange(0.3, changes: { vc.state.isWide = current }, completion: { _ in
            completions += 1
            completed.fulfill()
        })

        waitForCompletion(completed)
        XCTAssertEqual(vc.hookRuns, runsBefore, "an equal write schedules no pass", file: file, line: line)
        XCTAssertEqual(completions, 1, file: file, line: line)
        XCTAssertEqual(vc.bar.frame.width, Width.narrow, accuracy: 0.5, file: file, line: line)
    }

    func test_manualMode_animatesTheUpdatePassTheChangeCauses() {
        assertAnimatesTheChange(mode: .manual)
    }

    func test_nativeMode_animatesTheUpdatePassTheChangeCauses() throws {
        guard #available(iOS 26.0, *) else { throw XCTSkip("native path needs iOS 26") }
        assertAnimatesTheChange(mode: .native)
    }

    func test_manualMode_anEqualWrite_runsNoHookAndCompletesOnce() {
        assertAnEqualWriteCompletesWithoutAPass(mode: .manual)
    }

    func test_nativeMode_anEqualWrite_runsNoHookAndCompletesOnce() throws {
        guard #available(iOS 26.0, *) else { throw XCTSkip("native path needs iOS 26") }
        assertAnEqualWriteCompletesWithoutAPass(mode: .native)
    }
}
