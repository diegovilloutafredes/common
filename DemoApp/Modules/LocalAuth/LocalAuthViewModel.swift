//
//  LocalAuthViewModel.swift
//  DemoApp
//

import Common
import LocalAuthentication

// MARK: - LocalAuthViewModelProtocol
protocol LocalAuthViewModelProtocol: ViewModel {
    var title: String { get }
    var authTypeDescription: String { get }
    var authIconName: String { get }
    var canAuthenticate: Bool { get }
    func authenticate()
}

// MARK: - LocalAuthViewModelImpl
final class LocalAuthViewModelImpl: LocalAuthViewModelProtocol {
    let title = "Local Authentication"
    private let manager = LocalAuthenticationManager()
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
            dispatchOnMain {
                self?.view?.hideLoading()
                self?.view?.updateResult(success: success)
            }
        }
    }
}
