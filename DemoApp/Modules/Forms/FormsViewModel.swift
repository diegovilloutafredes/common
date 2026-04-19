//
//  FormsViewModel.swift
//  DemoApp
//

import Common

// MARK: - FormsViewProtocol
protocol FormsViewProtocol: AnyObject {
    func updateValidationStatus(isValid: Bool)
    func showFieldError(field: FormsViewModel.Field, message: String)
    func clearFieldError(field: FormsViewModel.Field)
}

// MARK: - FormsViewModelProtocol
protocol FormsViewModelProtocol: ViewModel {
    var title: String { get }
    func validate(field: FormsViewModel.Field, value: String)
    func submit(name: String, email: String, password: String)
}

// MARK: - FormsViewModel
final class FormsViewModel {
    enum Field: String {
        case name
        case email
        case password
    }

    let title = "Forms & TextFields"
    weak var view: FormsViewProtocol?

    private var fieldStates: [Field: Bool] = [.name: false, .email: false, .password: false]

    private var allFieldsValid: Bool { fieldStates.values.allSatisfy { $0 } }
}

// MARK: - FormsViewModelProtocol
extension FormsViewModel: FormsViewModelProtocol {
    func validate(field: Field, value: String) {
        let isValid: Bool
        switch field {
        case .name:
            isValid = value.count >= 2
            if !isValid && !value.isEmpty {
                view?.showFieldError(field: field, message: "Name must be at least 2 characters")
            } else {
                view?.clearFieldError(field: field)
            }
        case .email:
            isValid = value.contains("@") && value.contains(".")
            if !isValid && !value.isEmpty {
                view?.showFieldError(field: field, message: "Enter a valid email address")
            } else {
                view?.clearFieldError(field: field)
            }
        case .password:
            isValid = value.count >= 6
            if !isValid && !value.isEmpty {
                view?.showFieldError(field: field, message: "Password must be at least 6 characters")
            } else {
                view?.clearFieldError(field: field)
            }
        }
        fieldStates[field] = isValid
        view?.updateValidationStatus(isValid: allFieldsValid)
    }

    func submit(name: String, email: String, password: String) {
        Snackbar.show(.init(message: "Form submitted: \(name) (\(email))"))
    }
}
