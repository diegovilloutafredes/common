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
    func showSubmissionSuccess(message: String)
}

// MARK: - FormsViewModelProtocol
@MainActor
protocol FormsViewModelProtocol: ViewModel {
    var title: String { get }
    func validate(field: FormsViewModel.Field, value: String)
    func submit(name: String, email: String, password: String)
}

// MARK: - FormsViewModel
@MainActor
final class FormsViewModel {
    enum Field: String {
        case name
        case email
        case password
        case confirmPassword
    }

    let title = "Forms & TextFields"
    weak var view: FormsViewProtocol?

    // Validation is fully delegated to Common's FieldsValidator — no values, rules, or
    // touched-state are tracked by hand here.
    private lazy var validator = FieldsValidator<Field>(
        rules: [
            .name: [.notEmpty, .minLength(2)],
            .email: [.notEmpty, .email],
            .password: [.notEmpty, .minLength(6)],
            .confirmPassword: [.notEmpty, .matches(.password)]
        ],
        message: { field, rule in
            switch (field, rule) {
            case (.name, .minLength):          "Name must be at least 2 characters"
            case (.email, .email):             "Enter a valid email address"
            case (.password, .minLength):      "Password must be at least 6 characters"
            case (.confirmPassword, .matches): "Passwords must match"
            default:                           rule.defaultMessage
            }
        },
        onChange: { [weak self] state in
            guard let self else { return }
            self.view?.updateValidationStatus(isValid: state.isValid)
            state.fields.forEach { field, fieldState in
                if let message = fieldState.message {
                    self.view?.showFieldError(field: field, message: message)
                } else {
                    self.view?.clearFieldError(field: field)
                }
            }
        }
    )
}

// MARK: - FormsViewModelProtocol
extension FormsViewModel: FormsViewModelProtocol {
    func validate(field: Field, value: String) {
        validator.set(value, on: field)
    }

    func submit(name: String, email: String, password: String) {
        validator.touchAll()
        view?.showSubmissionSuccess(message: "Form submitted: \(name) (\(email))")
    }
}
