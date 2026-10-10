//
//  PresentationAnchorHostedTests.swift
//

import UIKit
import XCTest
import Common

/// Where presentations, dismissals and alerts go. Hosted: presenting needs controllers in the key window of a
/// foreground-active scene.
@MainActor
final class PresentationAnchorHostedTests: XCTestCase {

    /// Conforms to the three protocols and declares nothing else, as a type written before anchors existed does.
    private final class PlainPresenter: Presentable, Dismissable, AlertPresentable {}

    private final class AnchoredCoordinator: BaseCoordinator {
        weak var anchor: UIViewController?
        override var presentationAnchor: UIViewController? { anchor }
    }

    private final class AnchoredViewController: UIViewController, PresentationAnchorProviding {
        weak var anchor: UIViewController?
        var presentationAnchor: UIViewController? { anchor }
    }

    /// A visible window that isn't the key window, so its root is on screen without being the app's top-most controller.
    private var anchorWindow: UIWindow?

    override func setUp() async throws {
        try await super.setUp()
        UIView.setAnimationsEnabled(false)
    }

    override func tearDown() async throws {
        if let anchor = anchorWindow?.rootViewController, anchor.presentedViewController != nil {
            await transition("the anchor's presentations are dismissed") { anchor.dismiss(animated: false, completion: $0) }
        }
        anchorWindow?.isHidden = true
        anchorWindow = nil
        await dismissEverything()
        UIView.setAnimationsEnabled(true)
        try await super.tearDown()
    }

    // MARK: - Anchors

    func test_coordinatorAnchor_receivesItsAlerts() throws {
        let anchor = try makeAnchor()
        let host = try hostTopMost()
        let coordinator = AnchoredCoordinator(navigationController: UINavigationController())
        coordinator.anchor = anchor

        coordinator.presentAlertView(type: .genericError)

        XCTAssertTrue(anchor.presentedViewController is UIAlertController)
        XCTAssertNil(host.presentedViewController, "the alert no longer goes to the top-most controller")
    }

    func test_coordinatorAnchor_presentsFromTheSheetItPresents() async throws {
        let anchor = try makeAnchor()
        let sheet = UIViewController()
        await present(sheet, from: anchor)
        let coordinator = AnchoredCoordinator(navigationController: UINavigationController())
        coordinator.anchor = anchor
        let presented = UIViewController()

        await transition("the coordinator presents") { coordinator.present(.overCurrent, viewController: presented, animated: false, completion: $0) }

        XCTAssertTrue(presented.presentingViewController === sheet)
    }

    func test_coordinatorAnchor_dismissesTheSheetItPresents() async throws {
        let anchor = try makeAnchor()
        await present(UIViewController(), from: anchor)
        let coordinator = AnchoredCoordinator(navigationController: UINavigationController())
        coordinator.anchor = anchor

        await transition("the coordinator dismisses") { coordinator.dismiss(animated: false, completion: $0) }

        XCTAssertNil(anchor.presentedViewController)
    }

    func test_viewControllerAdoptingTheProtocol_presentsItsAlertsFromItsAnchor() throws {
        let anchor = try makeAnchor()
        let host = try hostTopMost()
        let viewController = AnchoredViewController()
        viewController.anchor = anchor

        viewController.presentAlertView(type: .genericError)

        XCTAssertTrue(anchor.presentedViewController is UIAlertController)
        XCTAssertNil(host.presentedViewController)
    }

    @available(*, deprecated, message: "Pins the deprecated viewController")
    func test_viewControllerProperty_ignoresTheAnchor() throws {
        let anchor = try makeAnchor()
        let navigation = UINavigationController()
        let coordinator = AnchoredCoordinator(navigationController: navigation)
        coordinator.anchor = anchor

        XCTAssertTrue(presentableTarget(of: coordinator) === navigation)
        XCTAssertTrue(dismissableTarget(of: coordinator) === navigation)
        XCTAssertTrue(alertTarget(of: coordinator) === UIApplication.shared.topMostViewController)
    }

    @available(*, deprecated, message: "Pins the deprecated viewController")
    private func presentableTarget<T: Presentable & Navigationable>(of presenter: T) -> UIViewController? { presenter.viewController }
    @available(*, deprecated, message: "Pins the deprecated viewController")
    private func dismissableTarget<T: Dismissable & Navigationable>(of presenter: T) -> UIViewController? { presenter.viewController }
    @available(*, deprecated, message: "Pins the deprecated viewController")
    private func alertTarget<T: AlertPresentable>(of presenter: T) -> UIViewController? { presenter.viewController }

    @available(*, deprecated, message: "Pins the deprecated viewController")
    func test_viewControllerProperty_ofATypeWithoutANavigationController_isTheTopMostController() throws {
        let host = try hostTopMost()
        let presenter = PlainPresenter()

        XCTAssertTrue(plainPresentableTarget(of: presenter) === host)
        XCTAssertTrue(plainDismissableTarget(of: presenter) === host)
        XCTAssertTrue(alertTarget(of: presenter) === host)
    }

    @available(*, deprecated, message: "Pins the deprecated viewController")
    private func plainPresentableTarget<T: Presentable>(of presenter: T) -> UIViewController? { presenter.viewController }
    @available(*, deprecated, message: "Pins the deprecated viewController")
    private func plainDismissableTarget<T: Dismissable>(of presenter: T) -> UIViewController? { presenter.viewController }

    // MARK: - Default targets

    func test_defaultCoordinator_presentsFromItsNavigationControllersTopMostPresentedController() async throws {
        let navigation = UINavigationController(rootViewController: UIViewController())
        await present(navigation, from: try hostTopMost())
        let sheet = UIViewController()
        await present(sheet, from: navigation)
        let coordinator = BaseCoordinator(navigationController: navigation)
        let presented = UIViewController()

        await transition("the coordinator presents") { coordinator.present(.overCurrent, viewController: presented, animated: false, completion: $0) }

        XCTAssertTrue(presented.presentingViewController === sheet)
    }

    func test_defaultCoordinator_offScreen_presentsItsAlertFromTheTopMostController() throws {
        let host = try hostTopMost()
        let offScreen = UINavigationController(rootViewController: UIViewController())
        let coordinator = BaseCoordinator(navigationController: offScreen)

        coordinator.presentAlertView(type: .genericError)

        XCTAssertTrue(UIApplication.shared.topMostViewController is UIAlertController, "the alert is on screen")
        XCTAssertTrue(host.presentedViewController is UIAlertController)
        XCTAssertNil(offScreen.presentedViewController)
    }

    func test_viewControllerAlert_presentsFromTheTopMostController() throws {
        let host = try hostTopMost()
        let offScreen = UIViewController()

        offScreen.presentAlertView(type: .genericError)

        XCTAssertTrue(host.presentedViewController is UIAlertController)
        XCTAssertNil(offScreen.presentedViewController)
    }

    func test_typeConformingToTheThreeProtocols_withoutAnAnchor_presentsFromTheTopMostController() throws {
        let host = try hostTopMost()

        PlainPresenter().presentAlertView(type: .emptyAlert)

        XCTAssertTrue(host.presentedViewController is UIAlertController)
    }

    func test_defaultCoordinator_presentingAfterDismissing_replacesWhatItsNavigationControllerPresents() async throws {
        let navigation = UINavigationController(rootViewController: UIViewController())
        await present(navigation, from: try hostTopMost())
        let sheet = UIViewController()
        await present(sheet, from: navigation)
        let coordinator = BaseCoordinator(navigationController: navigation)
        let replacement = UIViewController()

        await transition("the coordinator presents after dismissing") { coordinator.present(.dismissingCurrent, viewController: replacement, animated: false, completion: $0) }

        XCTAssertTrue(navigation.presentedViewController === replacement)
        XCTAssertNil(sheet.presentingViewController)
    }

    func test_defaultCoordinator_dismissesWhatItsNavigationControllerPresents() async throws {
        let navigation = UINavigationController(rootViewController: UIViewController())
        await present(navigation, from: try hostTopMost())
        await present(UIViewController(), from: navigation)
        let coordinator = BaseCoordinator(navigationController: navigation)

        await transition("the coordinator dismisses") { coordinator.dismiss(animated: false, completion: $0) }

        XCTAssertNil(navigation.presentedViewController)
        XCTAssertNotNil(navigation.presentingViewController, "its own navigation controller stays presented")
    }

    func test_defaultCoordinator_dismissingFromTheRoot_dismissesItsNavigationControllerToo() async throws {
        let host = try hostTopMost()
        let navigation = UINavigationController(rootViewController: UIViewController())
        await present(navigation, from: host)
        await present(UIViewController(), from: navigation)
        let coordinator = BaseCoordinator(navigationController: navigation)

        await transition("the coordinator dismisses from the root") { coordinator.dismiss(.fromRoot, animated: false, completion: $0) }

        XCTAssertNil(host.presentedViewController)
    }

    func test_typeWithoutANavigationController_presentsFromTheTopMostController() async throws {
        let host = try hostTopMost()
        let presented = UIViewController()

        await transition("the presenter presents") { PlainPresenter().present(.overCurrent, viewController: presented, animated: false, completion: $0) }

        XCTAssertTrue(host.presentedViewController === presented)
    }

    func test_typeWithoutANavigationController_presentingAfterDismissing_replacesTheTopMostController() async throws {
        let host = try hostTopMost()
        let sheet = UIViewController()
        await present(sheet, from: host)
        let replacement = UIViewController()

        await transition("the presenter presents after dismissing") { PlainPresenter().present(.dismissingCurrent, viewController: replacement, animated: false, completion: $0) }

        XCTAssertTrue(host.presentedViewController === replacement)
        XCTAssertNil(sheet.presentingViewController)
    }

    func test_typeWithoutANavigationController_dismissingFromTheRoot_dismissesEverythingPresented() async throws {
        let host = try hostTopMost()
        let sheet = UIViewController()
        await present(sheet, from: host)
        await present(UIViewController(), from: sheet)

        await transition("the presenter dismisses from the root") { PlainPresenter().dismiss(.fromRoot, animated: false, completion: $0) }

        XCTAssertNil(host.presentedViewController)
    }

    /// Pins the behavior as it is: the target is the top-most controller, which presents nothing, so there is
    /// nothing for it to dismiss and only the completion runs.
    func test_typeWithoutANavigationController_dismissingTheTopMost_dismissesNothing() async throws {
        let host = try hostTopMost()
        let sheet = UIViewController()
        await present(sheet, from: host)

        await transition("the presenter's completion runs") { PlainPresenter().dismiss(animated: false, completion: $0) }

        XCTAssertTrue(host.presentedViewController === sheet)
    }

    // MARK: - Helpers

    private func makeAnchor() throws -> UIViewController {
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        let window = UIWindow(windowScene: scene)
        let anchor = UIViewController()
        window.rootViewController = anchor
        window.isHidden = false
        window.layoutIfNeeded()
        anchorWindow = window
        XCTAssertNotNil(anchor.view.window, "precondition: the anchor is in the window hierarchy, so it can present")
        return anchor
    }

    /// The host app's top-most controller, which alerts are presented from by default.
    private func hostTopMost() throws -> UIViewController {
        try XCTUnwrap(UIApplication.shared.topMostViewController, "the host app has a key window")
    }

    private func present(_ viewController: UIViewController, from presenter: UIViewController) async {
        await transition("the presentation completes") { presenter.present(viewController, animated: false, completion: $0) }
    }

    /// Runs `start`, which calls its argument when a transition completes, and waits for that. It fails at the
    /// timeout instead of hanging: UIKit never calls the completion of a presentation it refuses.
    private func transition(_ description: String, _ start: (@escaping () -> Void) -> Void) async {
        let completed = expectation(description: description)
        start { completed.fulfill() }
        await fulfillment(of: [completed], timeout: transitionTimeout)
    }

    /// Dismisses everything presented over the host's root controller.
    private func dismissEverything() async {
        var root = UIApplication.shared.topMostViewController
        while let presenting = root?.presentingViewController { root = presenting }
        guard let root, root.presentedViewController != nil else { return }
        await transition("the host's presentations are dismissed") { root.dismiss(animated: false, completion: $0) }
    }
}
