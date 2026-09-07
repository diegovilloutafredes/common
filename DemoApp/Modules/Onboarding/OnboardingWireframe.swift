//
//  OnboardingWireframe.swift
//

import Common
import UIKit

// MARK: - OnboardingWireframe
enum OnboardingWireframe {
    @MainActor static func createModule(
        onRequested: @escaping Handler<OnboardingViewModel.Requested>,
        onPerformed: @escaping Handler<OnboardingViewModel.Performed>
    ) -> UIViewController {
        OnboardingViewController(viewModel: OnboardingViewModel(onRequested: onRequested, onPerformed: onPerformed))
    }
}
