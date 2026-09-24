//
//  OnboardingStep.swift
//

import UIKit

// MARK: - OnboardingStep
enum OnboardingStep: Int, OnboardingCellViewModel {
    case first = 0
    case second
    case third

    var title: String {
        switch self {
        case .first: "Welcome to \(Bundle.main.displayName)"
        case .second: "State flows one way"
        case .third: "Explore the modules"
        }
    }

    var subtitle: String {
        switch self {
        case .first: "Every screen in this app is built with Common's declarative UIKit DSL"
        case .second: "View models publish observable state, and each screen renders it in updateContent()"
        case .third: "Each module demonstrates one part of the framework, from networking to forms"
        }
    }

    var image: UIImage? {
        switch self {
        case .first: .init(systemName: "square.stack.3d.up.fill")
        case .second: .init(systemName: "arrow.triangle.branch")
        case .third: .init(systemName: "square.grid.2x2.fill")
        }
    }
}
