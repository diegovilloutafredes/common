//
//  SplashViewModel.swift
//

import UIKit

// MARK: - SplashViewModelProtocol
public protocol SplashViewModelProtocol {
    var backgroundColor: UIColor { get }
    var image: UIImage? { get }
}

// MARK: - Default implementation
extension SplashViewModelProtocol {
    public var backgroundColor: UIColor { .white }
    public var image: UIImage? { .named("AppIcon") }
}

// MARK: - SplashViewModel
public struct SplashViewModel: SplashViewModelProtocol {
    public init() {}
}
