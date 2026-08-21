//
//  LocalAuthViewModel.swift
//  DemoApp
//

import Common
import LocalAuthentication
import UIKit

// MARK: - LocalAuthViewModelProtocol
protocol LocalAuthViewModelProtocol: ViewModel {
    var title: String { get }
    var authTypeDescription: String { get }
    var authIconName: String { get }
    var canAuthenticate: Bool { get }
    func authenticate()
    func performAppleLogin(from context: UIViewController)
}

// MARK: - LocalAuthViewModelImpl
final class LocalAuthViewModelImpl: LocalAuthViewModelProtocol {
    let title = "Auth"
    private let manager = LocalAuthenticationManager()
    // Kept in a property: the manager is the authorization controller's
    // delegate and must outlive the sign-in flow.
    private let appleLogin = AppleLoginManager()
    weak var view: LocalAuthViewProtocol?

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
        view?.showLoading()
        manager.authenticate { [weak self] success in
            Task { @MainActor in
                self?.view?.hideLoading()
                self?.view?.updateResult(success: success)
            }
        }
    }

    func performAppleLogin(from context: UIViewController) {
        view?.updateAppleResult("Starting Sign in with Apple…")
        appleLogin.performLogin(from: context) { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success(let (credential, _)):
                    self?.view?.updateAppleResult("Signed in as \(credential.asAppleUser.id)")
                case .failure(let error):
                    // Expected without a Sign in with Apple entitlement — the
                    // demo surfaces the real outcome instead of pretending.
                    self?.view?.updateAppleResult("Apple sign-in failed: \(error.localizedDescription)")
                }
            }
        }
    }
}
