//
//  DeprecatedConformanceTests.swift
//

import UIKit
import XCTest
@testable import Common

/// The conformances that moved into deprecated extensions still exist at run time, so code and binaries that rely
/// on them keep working until a major release removes them.
@available(*, deprecated, message: "Pins conformances that are deprecated")
@MainActor
final class DeprecatedConformanceTests: XCTestCase {

    // MARK: - Module delegate

    func test_coordinator_isStillTheFourRequestProtocols() {
        let coordinator: AnyObject = BaseCoordinator(navigationController: UINavigationController())

        XCTAssertTrue(coordinator is ActivityControllerRequestable)
        XCTAssertTrue(coordinator is AlertRequestable)
        XCTAssertTrue(coordinator is DismissRequestable)
        XCTAssertTrue(coordinator is GoBackRequestable)
    }

    func test_coordinator_heldAsAModuleDelegate_receivesItsRequests() {
        final class RecordingCoordinator: BaseCoordinator {
            var dismissalRequests = 0
            var goBackRequests = 0
            override func onDismissRequested() { dismissalRequests += 1 }
            override func onGoBackRequested() { goBackRequests += 1 }
        }
        let coordinator = RecordingCoordinator(navigationController: UINavigationController())
        let delegate: BaseModuleDelegate = coordinator

        delegate.onDismissRequested()
        delegate.onGoBackRequested()

        XCTAssertEqual(coordinator.dismissalRequests, 1)
        XCTAssertEqual(coordinator.goBackRequests, 1)
    }

    // MARK: - Content reload

    func test_viewModelableController_isStillContentReloadable_andReloadsThroughIt() throws {
        final class ReloadableViewModel: ViewModel, ReloadContentRequestable {
            var reloadRequests = 0
            func onReloadContentRequested() { reloadRequests += 1 }
        }
        let viewModel = ReloadableViewModel()
        let controller: Any = BaseViewModelableViewController<ViewModel>(viewModel: viewModel)

        let reloadable = try XCTUnwrap(controller as? ContentReloadable)
        reloadable.reloadContent()

        XCTAssertEqual(viewModel.reloadRequests, 1)
    }

    // MARK: - View controller capabilities

    func test_viewController_isStillLargeTitleSettable_andOffsetResetable() {
        let controller: Any = UIViewController()

        XCTAssertTrue(controller is LargeTitleSettable)
        XCTAssertTrue(controller is OffsetResetable)
    }

    func test_largeTitles_stillFollowTheNavigationController() {
        let navigation = UINavigationController(rootViewController: UIViewController())

        navigation.topViewController?.enableLargeTitles()
        XCTAssertTrue(navigation.navigationBar.prefersLargeTitles)

        navigation.disableLargeTitles()
        XCTAssertFalse(navigation.navigationBar.prefersLargeTitles)
    }

    // MARK: - Data and String

    func test_data_isStillKeyable_withTheKeyItHad() throws {
        let data: Any = Data([1, 2, 3])

        let keyable = try XCTUnwrap(data as? Keyable)

        XCTAssertEqual(keyable.key, "3 bytes")
    }

    func test_thrownString_isCaughtAsThatString() {
        func fail() throws { throw "failed" }

        XCTAssertThrowsError(try fail()) { error in
            XCTAssertEqual(error as? String, "failed")
        }
    }
}
