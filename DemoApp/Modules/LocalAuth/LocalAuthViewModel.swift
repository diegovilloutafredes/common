//
//  LocalAuthViewModel.swift
//  DemoApp
//

import Common
import LocalAuthentication
import Observation
import UIKit

// MARK: - LocalAuthViewModelProtocol
@MainActor
protocol LocalAuthViewModelProtocol: ViewModel {
    var title: String { get }
    var authTypeDescription: String { get }
    var authIconName: String { get }
    var canAuthenticate: Bool { get }
    /// `nil` until the first attempt, then the last outcome.
    var authResult: Bool? { get }
    var isAuthenticating: Bool { get }
    var appleResultMessage: String? { get }
    func authenticate()
    func performAppleLogin(from context: UIViewController)
}

// MARK: - LocalAuthViewModelImpl
@Observable
@MainActor
final class LocalAuthViewModelImpl: LocalAuthViewModelProtocol {
    let title = "Auth"
    private(set) var authResult: Bool?
    private(set) var isAuthenticating = false
    private(set) var appleResultMessage: String?

    private let manager = LocalAuthenticationManager()
    // Kept in a property: the manager is the authorization controller's
    // delegate and must outlive the sign-in flow.
    private let appleLogin = AppleLoginManager()

    var authTypeDescription: String {
        manager.localAuthenticationType.asString
    }

    var authIconName: String {
        switch manager.localAuthenticationType {
        case .biometry(let type):
            switch type {
            case .faceId: "faceid"
            case .touchId: "touchid"
            case .opticId: "opticid"
            @unknown default: "person.fill"
            }
        case .passcode: "lock.fill"
        case .none: "lock.slash.fill"
        @unknown default: "questionmark.circle"
        }
    }

    var canAuthenticate: Bool { manager.canAuthenticate }

    func authenticate() {
        isAuthenticating = true
        manager.authenticate { [weak self] success in
            Task { @MainActor [weak self] in
                guard let self else { return }
                isAuthenticating = false
                authResult = success
            }
        }
    }

    func performAppleLogin(from context: UIViewController) {
        appleResultMessage = "Starting Sign in with Apple…"
        appleLogin.performLogin(from: context) { [weak self] result in
            Task { @MainActor [weak self] in
                guard let self else { return }
                switch result {
                case .success(let (credential, _)):
                    appleResultMessage = "Signed in as \(credential.asAppleUser.id)"
                case .failure(let error):
                    // Expected without a Sign in with Apple entitlement — the
                    // demo surfaces the real outcome instead of pretending.
                    appleResultMessage = "Apple sign-in failed: \(error.localizedDescription)"
                }
            }
        }
    }
}
