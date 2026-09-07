//
//  FormsViewModel.swift
//  DemoApp
//

import Common
import Observation

// MARK: - FormsViewModelProtocol
@MainActor
protocol FormsViewModelProtocol: ViewModel {
    var title: String { get }
    /// `nil` until the first keystroke; then the validator's latest state.
    var validation: FieldsValidator<FormsViewModel.Field>.State? { get }
    /// The one-shot submission confirmation; validation itself is state.
    var event: ViewEvent<FormsViewModel.Event>? { get }
    func validate(field: FormsViewModel.Field, value: String)
    func submit(name: String, email: String, password: String)
}

// MARK: - FormsViewModel
@Observable
@MainActor
final class FormsViewModel {
    enum Field: String {
        case name
        case email
        case password
        case confirmPassword
    }

    enum Event { case submitted(message: String) }

    let title = "Forms & TextFields"
    private(set) var validation: FieldsValidator<Field>.State?
    private(set) var event: ViewEvent<Event>?

    // Validation is fully delegated to Common's FieldsValidator — no values, rules, or
    // touched-state are tracked by hand here. Its onChange just publishes the new state.
    @ObservationIgnored private lazy var validator = FieldsValidator<Field>(
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
        onChange: { [weak self] state in self?.validation = state }
    )
}

// MARK: - FormsViewModelProtocol
extension FormsViewModel: FormsViewModelProtocol {
    func validate(field: Field, value: String) {
        validator.set(value, on: field)
    }

    func submit(name: String, email: String, password: String) {
        validator.touchAll()
        event = .init(.submitted(message: "Form submitted: \(name) (\(email))"))
    }
}
