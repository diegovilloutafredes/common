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
    private let onAbortAll: Action

    init(
        navigationController: UINavigationController,
        depth: Int,
        maxDepth: Int,
        onEvent: @escaping Handler<CoordinatorEvent>,
        onAbortAll: @escaping Action,
        onPerformed: Handler<Coordinator>? = nil
    ) {
        self.depth = depth
        self.maxDepth = maxDepth
        self.onEvent = onEvent
        self.onAbortAll = onAbortAll
        super.init(navigationController: navigationController, onPerformed: onPerformed)
    }

    override func start() {
        // Note: no cancel wiring — swipe-back/back-button cancellation is
        // detected automatically by BaseCoordinator's removal tracking.
        let vc = ChildFlowViewController(
            depth: depth,
            maxDepth: maxDepth,
            onRequested: { [weak self] request in
                switch request {
                case .goDeeper: self?.launchGrandchild()
                case .abortAll: self?.onAbortAll()
                }
            },
            onPerformed: { [weak self] result in
                switch result {
                case .complete: self?.finish()
                }
            }
        )
        push(vc)
        onEvent(CoordinatorEvent(icon: "🚀", message: "Depth \(depth) coordinator started", delta: +1))
    }

    override func finish() {
        onEvent(CoordinatorEvent(icon: "✅", message: "Depth \(depth) coordinator finished", delta: -1))
        super.finish()
    }

    override func cancel() {
        onEvent(CoordinatorEvent(icon: "❌", message: "Depth \(depth) coordinator cancelled — no VC code", delta: -1))
        super.cancel()
    }

    private func launchGrandchild() {
        let child = ChildFlowCoordinator(
            navigationController: navigationController,
            depth: depth + 1,
            maxDepth: maxDepth,
            onEvent: onEvent,
            onAbortAll: onAbortAll,
            onPerformed: { [weak self] _ in self?.pop() }
        )
        addChildAndStart(child)
    }
}
