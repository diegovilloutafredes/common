//
//  CoordinatorDemoCoordinator.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - CoordinatorDemoCoordinator

final class CoordinatorDemoCoordinator: BaseCoordinator {
    private weak var viewModel: CoordinatorDemoViewModel?
    private var activeCount = 0

    override func start() {
        let vm = CoordinatorDemoViewModel()
        vm.delegate = self
        viewModel = vm
        let vc = CoordinatorDemoViewController(viewModel: vm)
        vm.view = vc
        push(vc)
    }

    private var navStackCount: Int { navigationController.viewControllers.count }

    private func launchFlow(maxDepth: Int) {
        let child = ChildFlowCoordinator(
            navigationController: navigationController,
            depth: 1,
            maxDepth: maxDepth,
            onEvent: { [weak self] event in
                guard let self else { return }
                activeCount += event.delta
                viewModel?.logAndRefresh(event, children: activeCount, navStack: navStackCount)
            },
            onPerformed: { [weak self] _ in self?.pop() }
        )
        addChildAndStart(child)
    }
}

// MARK: - CoordinatorDemoViewModelDelegate

extension CoordinatorDemoCoordinator: CoordinatorDemoViewModelDelegate {
    func didRequestLaunchChild() { launchFlow(maxDepth: 1) }
    func didRequestLaunchDeepFlow() { launchFlow(maxDepth: 3) }
    func didRequestStatsRefresh() {
        viewModel?.refreshStats(children: activeCount, navStack: navStackCount)
    }
}
