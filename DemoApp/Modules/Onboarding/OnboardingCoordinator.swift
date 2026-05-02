//
//  OnboardingCoordinator.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - OnboardingCoordinator

final class OnboardingCoordinator: BaseCoordinator {
    override func start() {
        let vc = OnboardingWireframe.createModule { [weak self] _ in
            self?.pop()
        }
        push(vc)
    }
}
