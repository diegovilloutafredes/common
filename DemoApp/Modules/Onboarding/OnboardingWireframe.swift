//
//  OnboardingWireframe.swift
//

import Common
import UIKit

// MARK: - OnboardingWireframe
enum OnboardingWireframe {
    static func createModule(with onRequested: @escaping Handler<OnboardingViewModel.OnRequested>) -> UIViewController {
        let viewModel = OnboardingViewModel(onRequested: onRequested)
        return OnboardingViewController(viewModel: viewModel)
            .with { viewModel.view = $0 }
    }
}
