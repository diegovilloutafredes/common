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

    // Current field values — validity derived, never stored separately
    private var name = ""
    private var email = ""
    private var password = ""

    // Per-field validation rules
    private func isValid(_ field: Field, value: String) -> Bool {
        switch field {
        case .name:     return value.count >= 2
        case .email:    return value.contains("@") && value.contains(".")
        case .password: return value.count >= 6
        }
    }

    private func errorMessage(for field: Field, value: String) -> String? {
        guard !value.isEmpty, !isValid(field, value: value) else { return nil }
        switch field {
        case .name:     return "Name must be at least 2 characters"
        case .email:    return "Enter a valid email address"
        case .password: return "Password must be at least 6 characters"
        }
    }

    private var allFieldsValid: Bool {
        isValid(.name, value: name) && isValid(.email, value: email) && isValid(.password, value: password)
    }
}

// MARK: - FormsViewModelProtocol
extension FormsViewModel: FormsViewModelProtocol {
    func validate(field: Field, value: String) {
        switch field {
        case .name:     name = value
        case .email:    email = value
        case .password: password = value
        }

        if let message = errorMessage(for: field, value: value) {
            view?.showFieldError(field: field, message: message)
        } else {
            view?.clearFieldError(field: field)
        }
        view?.updateValidationStatus(isValid: allFieldsValid)
    }

    func submit(name: String, email: String, password: String) {
        Snackbar.show(.init(message: "Form submitted: \(name) (\(email))"))
    }
}
