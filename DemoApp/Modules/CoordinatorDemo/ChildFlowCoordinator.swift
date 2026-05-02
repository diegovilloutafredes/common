//
//  ChildFlowCoordinator.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - ChildFlowCoordinator

final class ChildFlowCoordinator: BaseCoordinator {
    private let depth: Int
    private let maxDepth: Int
    private let onEvent: Handler<CoordinatorEvent>

    init(
        navigationController: UINavigationController,
        depth: Int,
        maxDepth: Int,
        onEvent: @escaping Handler<CoordinatorEvent>,
        onPerformed: Handler<Coordinator>? = nil
    ) {
        self.depth = depth
        self.maxDepth = maxDepth
        self.onEvent = onEvent
        super.init(navigationController: navigationController, onPerformed: onPerformed)
    }

    override func start() {
        let vc = ChildFlowViewController(depth: depth, maxDepth: maxDepth)
        vc.onComplete = { [weak self] in self?.finish() }
        vc.onCancel = { [weak self] in self?.cancel() }
        vc.onGoDeeper = { [weak self] in self?.launchGrandchild() }
        push(vc)
        onEvent(CoordinatorEvent(icon: "🚀", message: "Depth \(depth) coordinator started", delta: +1))
    }

    override func finish() {
        onEvent(CoordinatorEvent(icon: "✅", message: "Depth \(depth) coordinator finished", delta: -1))
        super.finish()
    }

    override func cancel() {
        onEvent(CoordinatorEvent(icon: "❌", message: "Depth \(depth) coordinator cancelled", delta: -1))
        super.cancel()
    }

    private func launchGrandchild() {
        let child = ChildFlowCoordinator(
            navigationController: navigationController,
            depth: depth + 1,
            maxDepth: maxDepth,
            onEvent: onEvent,
            onPerformed: { [weak self] _ in self?.pop() }
        )
        addChildAndStart(child)
    }
}
