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
    var canAuthenticate: Bool { get }
    func authenticate(result: @escaping Handler<Bool>)
}

// MARK: - LocalAuthViewModelImpl
final class LocalAuthViewModelImpl: LocalAuthViewModelProtocol {
    let title = "Local Authentication"
    private let manager = LocalAuthenticationManager()

    var authTypeDescription: String { manager.localAuthenticationType.asString }
    var canAuthenticate: Bool { manager.canAuthenticate }

    func authenticate(result: @escaping Handler<Bool>) {
        manager.authenticate(result: result)
    }
}
