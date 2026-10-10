//
//  ReloadContentForwardingTests.swift
//

import XCTest
@testable import Common

/// The deprecated `reloadContent()` still reaches a view model that adopts `ReloadContentRequestable`.
@available(*, deprecated, message: "Pins the deprecated reloadContent()")
@MainActor
final class ReloadContentForwardingTests: XCTestCase {

    private final class ReloadableViewModel: ViewModel, ReloadContentRequestable {
        private(set) var reloadRequests = 0
        func onReloadContentRequested() { reloadRequests += 1 }
    }

    func test_reloadContent_asksTheViewModelOnce() {
        let viewModel = ReloadableViewModel()
        let controller = BaseViewModelableViewController<ViewModel>(viewModel: viewModel)

        controller.reloadContent()

        XCTAssertEqual(viewModel.reloadRequests, 1)
    }

    func test_reloadContent_afterTheViewModelIsReplaced_asksTheNewOneOnly() {
        let replaced = ReloadableViewModel()
        let current = ReloadableViewModel()
        let controller = BaseViewModelableViewController<ViewModel>(viewModel: replaced)

        controller.viewModel = current
        controller.reloadContent()

        XCTAssertEqual(replaced.reloadRequests, 0)
        XCTAssertEqual(current.reloadRequests, 1)
    }
}
