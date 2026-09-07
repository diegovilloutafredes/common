//
//  CoordinatorDemoCoordinator.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - CoordinatorDemoCoordinator

final class CoordinatorDemoCoordinator: BaseCoordinator {
    private weak var viewModel: CoordinatorDemoViewModel?
    private weak var moduleViewController: UIViewController?
    private var activeCount = 0

    override func start() {
        let module = CoordinatorDemoWireframe.createModule { [weak self] request in
            guard let self else { return }
            switch request {
            case .launchChild: launchFlow(maxDepth: 1)
            case .launchDeepFlow: launchFlow(maxDepth: 3)
            case .presentSheet: presentSheet()
            case .refreshStats: viewModel?.refreshStats(children: activeCount, navStack: navStackCount)
            }
        }
        viewModel = module.viewModel
        moduleViewController = module.viewController
        push(module.viewController)
    }

    private var navStackCount: Int { navigationController.viewControllers.count }

    private func emit(_ event: CoordinatorEvent) {
        activeCount += event.delta
        viewModel?.logAndRefresh(event, children: activeCount, navStack: navStackCount)
    }

    private func launchFlow(maxDepth: Int) {
        let child = ChildFlowCoordinator(
            navigationController: navigationController,
            depth: 1,
            maxDepth: maxDepth,
            onEvent: { [weak self] event in self?.emit(event) },
            onAbortAll: { [weak self] in self?.abortAll() },
            onPerformed: { [weak self] _ in self?.pop() }
        )
        addChildAndStart(child)
    }

    /// Pops straight back to the hub: every stacked child coordinator detects
    /// its entry screen leaving the stack and cancels itself, cascading through
    /// the subtree — no per-child teardown code anywhere.
    private func abortAll() {
        guard let moduleViewController else { return }
        emit(CoordinatorEvent(icon: "🛑", message: "pop(.to(hub)) — every stacked child auto-cancels", delta: 0))
        pop(.to(viewController: moduleViewController))
    }

    /// Presents a modal flow as a medium-detent sheet, configured through the
    /// UISheetPresentationController chainables; dismissal routes back through
    /// the coordinator's dismiss().
    private func presentSheet() {
        let sheet = SheetFlowViewController(canSwap: true) { [weak self] request in
            guard let self else { return }
            switch request {
            case .dismiss:
                dismiss()
                emit(CoordinatorEvent(icon: "📥", message: "Sheet dismissed via coordinator dismiss()", delta: 0))
            case .swap:
                swapSheet()
            }
        }
        sheet.sheetPresentationController?
            .detents([.medium()])
            .prefersGrabberVisible(true)
            .preferredCornerRadius(16)
        present(.overCurrent, viewController: sheet)
        emit(CoordinatorEvent(icon: "📤", message: "Sheet presented — medium detent via chainables", delta: 0))
    }

    /// Replaces the presented sheet in one call: present(.dismissingCurrent)
    /// dismisses whatever is on top, then presents the new controller.
    private func swapSheet() {
        let replacement = SheetFlowViewController { [weak self] request in
            guard let self, case .dismiss = request else { return }
            dismiss()
            emit(CoordinatorEvent(icon: "📥", message: "Replacement sheet dismissed", delta: 0))
        }
        replacement.sheetPresentationController?
            .detents([.medium()])
            .prefersGrabberVisible(true)
            .preferredCornerRadius(16)
        present(.dismissingCurrent, viewController: replacement)
        emit(CoordinatorEvent(icon: "🔁", message: "Sheet swapped via present(.dismissingCurrent)", delta: 0))
    }
}
