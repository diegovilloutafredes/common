//
//  OnboardingCoordinator.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - OnboardingCoordinator

final class OnboardingCoordinator: BaseCoordinator {
    override func start() {
        let vc = OnboardingWireframe.createModule { [weak self] action in
            guard let self else { return }
            switch action {
            case .begin:
                // finish() = success path: removes coordinator from parent, fires onPerformed
                finish()
                pop()
            case .skip:
                // cancel() = abandonment path: removes coordinator from parent, no onPerformed
                cancel()
                pop()
            }
        }
        push(vc)
    }
}
