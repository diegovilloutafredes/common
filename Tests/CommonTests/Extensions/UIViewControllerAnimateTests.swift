//
//  UIViewControllerAnimateTests.swift
//

import XCTest
@testable import Common

/// `animate(_:delay:options:animations:completion:)` and `animateConstraints(_:options:constraintChanges:completion:)`
/// called on the main thread: the changes run before the call returns, and the completion is called once.
@MainActor
final class UIViewControllerAnimateTests: XCTestCase {

    private var window: UIWindow!
    private var controller: UIViewController!

    override func setUp() {
        super.setUp()
        controller = UIViewController()
        window = UIWindow(frame: .init(x: 0, y: 0, width: 320, height: 640))
        window.rootViewController = controller
        window.makeKeyAndVisible()
    }

    override func tearDown() {
        window.isHidden = true
        window = nil
        controller = nil
        super.tearDown()
    }

    func test_animate_onTheMainThread_runsTheAnimations_andCompletesOnce() {
        var ran = false
        var completions = 0
        let completed = expectation(description: "completion")

        controller.animate(0.01, animations: { ran = true }, completion: { _ in
            completions += 1
            completed.fulfill()
        })

        XCTAssertTrue(ran, "on the main thread the animations run before animate returns")
        wait(for: [completed], timeout: 5)
        RunLoop.main.run(until: Date().addingTimeInterval(0.1))
        XCTAssertEqual(completions, 1)
    }

    func test_animateConstraints_onTheMainThread_runsTheChanges_andCompletesOnce() {
        var changed = false
        var completions = 0
        let completed = expectation(description: "completion")

        controller.animateConstraints(0.01, constraintChanges: { changed = true }, completion: { _ in
            completions += 1
            completed.fulfill()
        })

        XCTAssertTrue(changed, "on the main thread the constraint changes run before animateConstraints returns")
        wait(for: [completed], timeout: 5)
        RunLoop.main.run(until: Date().addingTimeInterval(0.1))
        XCTAssertEqual(completions, 1)
    }
}
