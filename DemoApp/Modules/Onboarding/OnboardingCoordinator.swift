//
//  OnboardingCoordinator.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - OnboardingCoordinator

final class OnboardingCoordinator: BaseCoordinator {
    override func start() {
        let vc = OnboardingWireframe.createModule(
            onRequested: { [weak self] request in
                guard let self else { return }
                switch request {
                case .skip:
                    // cancel() = abandonment path: removes coordinator from parent, no onPerformed
                    cancel()
                    pop()
                }
            },
            onPerformed: { [weak self] result in
                guard let self else { return }
                switch result {
                case .begin:
                    // finish() = success path: removes coordinator from parent, fires onPerformed
                    finish()
                    pop()
                }
            }
        )
        push(vc)
    }
}
