//
//  CoordinatorDemoCoordinator.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - CoordinatorDemoCoordinator

final class CoordinatorDemoCoordinator: BaseCoordinator {
    private weak var viewModel: CoordinatorDemoViewModel?

    override func start() {
        let vm = CoordinatorDemoViewModel()
        vm.delegate = self
        viewModel = vm
        let vc = CoordinatorDemoViewController(viewModel: vm)
        vm.view = vc
        push(vc)
    }
}

// MARK: - CoordinatorDemoViewModelDelegate

extension CoordinatorDemoCoordinator: CoordinatorDemoViewModelDelegate {
    func coordinatorDemoDidRequestLaunch() {
        viewModel?.setStatus(.childRunning)
        let child = ChildFlowCoordinator(
            navigationController: navigationController,
            onCancelled: { [weak self] in self?.viewModel?.setStatus(.cancelled) },
            onPerformed: { [weak self] _ in
                self?.viewModel?.setStatus(.finished)
                self?.pop()
            }
        )
        addChildAndStart(child)
    }
}
