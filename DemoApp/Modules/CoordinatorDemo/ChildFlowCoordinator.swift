//
//  ChildFlowCoordinator.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - ChildFlowCoordinator

final class ChildFlowCoordinator: BaseCoordinator {
    private let onCancelled: () -> Void

    init(
        navigationController: UINavigationController,
        onCancelled: @escaping () -> Void,
        onPerformed: Handler<Coordinator>? = nil
    ) {
        self.onCancelled = onCancelled
        super.init(navigationController: navigationController, onPerformed: onPerformed)
    }

    override func start() {
        let vc = ChildFlowViewController()
        vc.onComplete = { [weak self] in self?.finish() }
        vc.onCancel = { [weak self] in self?.cancel() }
        push(vc)
    }

    override func cancel() {
        super.cancel()
        onCancelled()
    }
}
