//
//  ContentUpdateTraitsTests.swift
//

import UIKit
import XCTest
@testable import Common

/// What each base under test exposes: how many times its hook ran, and the border color it rendered last.
@MainActor
private protocol TraitRendering: AnyObject {
    var runs: Int { get }
    var renderedBorder: CGColor? { get }
}

/// A hook that sets a layer color through `cgColor`, as `borderColor(_:)` does, depends on the interface style. Each test
/// hosts a base in a window, switches the window from light to dark, and counts the hook's runs: in the manual mode only
/// a class that declares the style in `contentUpdateTraits` runs again, and in the native mode UIKit re-runs every one.
@available(iOS 17.0, *)
@MainActor
final class ContentUpdateTraitsTests: XCTestCase {

    private class PlainView: BaseView, TraitRendering {
        private(set) var runs: Int = .zero
        var renderedBorder: CGColor? { layer.borderColor }
        override func updateContent() {
            runs += 1
            borderColor(.label)
        }
    }

    private class PlainCell: BaseCell, TraitRendering {
        private(set) var runs: Int = .zero
        var renderedBorder: CGColor? { layer.borderColor }
        override func updateContent() {
            runs += 1
            borderColor(.label)
        }
    }

    private class PlainReusableView: BaseReusableView, TraitRendering {
        private(set) var runs: Int = .zero
        var renderedBorder: CGColor? { layer.borderColor }
        override func updateContent() {
            runs += 1
            borderColor(.label)
        }
    }

    private class PlainViewController: BaseViewController, TraitRendering {
        private(set) var runs: Int = .zero
        var renderedBorder: CGColor? { viewIfLoaded?.layer.borderColor }
        override func updateContent() {
            super.updateContent()
            runs += 1
            view.borderColor(.label)
        }
    }

    private final class DeclaringView: PlainView {
        override class var contentUpdateTraits: [UITrait] { [UITraitUserInterfaceStyle.self] }
    }

    private final class DeclaringCell: PlainCell {
        override class var contentUpdateTraits: [UITrait] { [UITraitUserInterfaceStyle.self] }
    }

    private final class DeclaringReusableView: PlainReusableView {
        override class var contentUpdateTraits: [UITrait] { [UITraitUserInterfaceStyle.self] }
    }

    private final class DeclaringViewController: PlainViewController {
        override class var contentUpdateTraits: [UITrait] { [UITraitUserInterfaceStyle.self] }
    }

    private var windows: [UIWindow] = []

    override func tearDown() {
        ObservationMode.override = nil
        windows.forEach { $0.isHidden = true }
        windows = []
        super.tearDown()
    }

    private static let lightBorder = UIColor.label.resolvedColor(with: .init(userInterfaceStyle: .light)).cgColor
    private static let darkBorder = UIColor.label.resolvedColor(with: .init(userInterfaceStyle: .dark)).cgColor

    /// One of each base, without a declaration. Created after the test sets the mode: a base reads it when it sets up.
    private func plainSubjects() -> [(kind: String, subject: TraitRendering)] {
        [("view", PlainView()), ("cell", PlainCell(frame: .zero)), ("reusable view", PlainReusableView(frame: .zero)),
         ("controller", PlainViewController())]
    }

    /// One of each base, declaring the interface style.
    private func declaringSubjects() -> [(kind: String, subject: TraitRendering)] {
        [("view", DeclaringView()), ("cell", DeclaringCell(frame: .zero)),
         ("reusable view", DeclaringReusableView(frame: .zero)), ("controller", DeclaringViewController())]
    }

    private func makeWindow(style: UIUserInterfaceStyle) -> UIWindow {
        let window = UIWindow(frame: .init(x: .zero, y: .zero, width: 320, height: 480))
        window.overrideUserInterfaceStyle = style
        window.isHidden = false
        windows.append(window)
        return window
    }

    /// Lays the window out until it is quiet: a visible window also lays out on its own run-loop turns.
    private func settle(_ window: UIWindow) {
        for _ in 0..<3 {
            window.layoutIfNeeded()
            RunLoop.main.run(until: Date().addingTimeInterval(0.05))
        }
    }

    /// Hosts `subject` in a light window, then switches the window to dark, and returns the runs the switch caused.
    private func runsCausedBySwitchingToDark(_ subject: TraitRendering) -> Int {
        let window = makeWindow(style: .light)
        if let controller = subject as? UIViewController {
            window.rootViewController = controller
        } else if let view = subject as? UIView {
            view.frame = .init(x: .zero, y: .zero, width: 100, height: 50)
            window.addSubview(view)
        }
        settle(window)
        let before = subject.runs
        window.overrideUserInterfaceStyle = .dark
        settle(window)
        return subject.runs - before
    }

    // MARK: - Manual mode

    func test_manualMode_aDeclaredStyle_aStyleSwitchRerunsTheHookWithTheDarkColor() {
        ObservationMode.override = .manual
        for (kind, subject) in declaringSubjects() {
            XCTAssertEqual(runsCausedBySwitchingToDark(subject), 1, kind)
            XCTAssertEqual(subject.renderedBorder, Self.darkBorder, kind)
        }
    }

    func test_manualMode_noDeclaration_aStyleSwitchDoesNotRerunTheHook() {
        ObservationMode.override = .manual
        for (kind, subject) in plainSubjects() {
            XCTAssertEqual(runsCausedBySwitchingToDark(subject), .zero, kind)
            XCTAssertEqual(subject.renderedBorder, Self.lightBorder, "\(kind): the border keeps the light color")
        }
    }

    /// The cost of a declaration: a cell bound outside a window, as a list binds a cell before showing it, renders again
    /// on joining a window only when the window's style differs from the one it was bound with.
    private func runsOnJoining(windowOfTheBoundStyle sameStyle: Bool) -> Int {
        ObservationMode.override = .manual
        let cell = DeclaringCell(frame: .init(x: .zero, y: .zero, width: 100, height: 40))
        cell.updateContentIfNeeded()
        XCTAssertEqual(cell.runs, 1, "bound outside a window")
        let bound: UIUserInterfaceStyle = cell.traitCollection.userInterfaceStyle == .dark ? .dark : .light
        let window = makeWindow(style: sameStyle ? bound : (bound == .dark ? .light : .dark))
        window.addSubview(cell)
        settle(window)
        return cell.runs - 1
    }

    func test_manualMode_firstDisplay_inAWindowOfTheBoundStyle_rendersNoMore() {
        XCTAssertEqual(runsOnJoining(windowOfTheBoundStyle: true), .zero)
    }

    func test_manualMode_firstDisplay_inAWindowOfAnotherStyle_rendersOnceMore() {
        XCTAssertEqual(runsOnJoining(windowOfTheBoundStyle: false), 1)
    }

    // MARK: - Native mode

    func test_nativeMode_aDeclaredStyle_aStyleSwitchRerunsTheHookOnce() throws {
        guard #available(iOS 26.0, *) else { throw XCTSkip("native path needs iOS 26") }
        ObservationMode.override = .native
        for (kind, subject) in declaringSubjects() {
            XCTAssertEqual(runsCausedBySwitchingToDark(subject), 1, "\(kind): the declaration adds no run")
            XCTAssertEqual(subject.renderedBorder, Self.darkBorder, kind)
        }
    }

    func test_nativeMode_noDeclaration_aStyleSwitchRerunsTheHookOnce() throws {
        guard #available(iOS 26.0, *) else { throw XCTSkip("native path needs iOS 26") }
        ObservationMode.override = .native
        for (kind, subject) in plainSubjects() {
            XCTAssertEqual(runsCausedBySwitchingToDark(subject), 1, kind)
            XCTAssertEqual(subject.renderedBorder, Self.darkBorder, kind)
        }
    }
}
