//
//  FieldsValidator.swift
//  Common
//

import Foundation

// MARK: - FieldsValidator

/// A reactive, declarative form-field validator.
///
/// Declare a set of ``Rule``s per field, feed values with ``set(_:on:)``, and receive a
/// recomputed ``State`` through `onChange` after every assignment. Rules are pure declarations
/// decoupled from the values they check, so no placeholder seeding is required: a field that has
/// never been assigned a value is evaluated as the empty string `""`, which means an untouched
/// required field is invalid from the start.
///
/// Cross-field rules (``Rule/matches(_:)``, ``Rule/differs(from:)``) reference another field and are
/// resolved against its current value at evaluation time. Error *display* is gated by per-field
/// touched-state — a field surfaces errors only once ``set(_:on:)`` has been called on it — while
/// *validity* always reflects every field.
@MainActor
public final class FieldsValidator<Field: Hashable> {

    private let rules: [Field: [Rule]]
    private let message: ((Field, Rule) -> String)?
    private let onChange: (State) -> Void

    private var values: [Field: String] = [:]
    private var touched: Set<Field> = []

    /// Creates a validator.
    /// - Parameters:
    ///   - rules: The rules to enforce per field.
    ///   - message: Resolves the message for a failing `(field, rule)`. Falls back to
    ///     ``Rule/defaultMessage`` when `nil` or when it returns a value. Returning `""` suppresses
    ///     that rule from display while still enforcing its validity.
    ///   - onChange: Called exactly once per ``set(_:on:)`` / ``touchAll()`` with the new state.
    public init(
        rules: [Field: [Rule]],
        message: ((Field, Rule) -> String)? = nil,
        onChange: @escaping (State) -> Void
    ) {
        self.rules = rules
        self.message = message
        self.onChange = onChange
    }

    /// Assigns `value` to `field`, marks it touched, re-evaluates, and fires `onChange` once.
    /// A `nil` value is treated as the empty string `""`.
    public func set(_ value: String?, on field: Field) {
        values[field] = value ?? ""
        touched.insert(field)
        onChange(state)
    }

    /// Marks every declared field as touched so all currently-failing rules become displayable,
    /// then fires `onChange` once. Useful for submit-time validation.
    public func touchAll() {
        rules.keys.forEach { touched.insert($0) }
        onChange(state)
    }

    /// The current validation snapshot.
    public var state: State {
        var fields: [Field: FieldState] = [:]
        var isValid = true

        for (field, fieldRules) in rules {
            let value = values[field] ?? ""
            let failing = fieldRules.filter { !$0.isSatisfied(by: value, in: values) }
            if !failing.isEmpty { isValid = false }

            let isTouched = touched.contains(field)
            let errors: [Failure] = isTouched
                ? failing.map { Failure(rule: $0, message: message?(field, $0) ?? $0.defaultMessage) }
                : []

            fields[field] = FieldState(isValid: failing.isEmpty, isTouched: isTouched, errors: errors)
        }

        return State(isValid: isValid, fields: fields)
    }
}

// MARK: - Rule

public extension FieldsValidator {

    /// A pure validation declaration, carrying no value of its own.
    enum Rule: Equatable {
        /// The value is non-empty.
        case notEmpty
        /// The value has at least `Int` characters.
        case minLength(Int)
        /// The value has at most `Int` characters.
        case maxLength(Int)
        /// The value contains at least one letter.
        case containsLetter
        /// The value contains at least one lowercase letter.
        case containsLowercase
        /// The value contains at least one uppercase letter.
        case containsUppercase
        /// The value contains at least one decimal digit.
        case containsNumber
        /// The value contains at least one scalar from the given set.
        case contains(CharacterSet)
        /// The value is a valid email address.
        case email
        /// The value is a valid RUT.
        case rut
        /// The value equals another field's current value.
        case matches(Field)
        /// The value differs from another field's current value.
        case differs(from: Field)

        func isSatisfied(by value: String, in values: [Field: String]) -> Bool {
            switch self {
            case .notEmpty: !value.isEmpty
            case .minLength(let min): value.count >= min
            case .maxLength(let max): value.count <= max
            case .containsLetter: Self.value(value, containsAnyOf: .letters)
            case .containsLowercase: Self.value(value, containsAnyOf: .lowercaseLetters)
            case .containsUppercase: Self.value(value, containsAnyOf: .uppercaseLetters)
            case .containsNumber: Self.value(value, containsAnyOf: .decimalDigits)
            case .contains(let set): Self.value(value, containsAnyOf: set)
            case .email: value.isValidEmail
            case .rut: value.isRUT
            case .matches(let other): value == (values[other] ?? "")
            case .differs(let other): value != (values[other] ?? "")
            }
        }

        private static func value(_ value: String, containsAnyOf set: CharacterSet) -> Bool {
            value.unicodeScalars.contains { set.contains($0) }
        }

        /// A non-empty English message used when no `message` resolver supplies one.
        public var defaultMessage: String {
            switch self {
            case .notEmpty: "This field is required."
            case .minLength(let min): "Must be at least \(min) characters."
            case .maxLength(let max): "Must be at most \(max) characters."
            case .containsLetter: "Must contain at least one letter."
            case .containsLowercase: "Must contain a lowercase letter."
            case .containsUppercase: "Must contain an uppercase letter."
            case .containsNumber: "Must contain a number."
            case .contains: "Contains an invalid character."
            case .email: "Enter a valid email address."
            case .rut: "Enter a valid RUT."
            case .matches: "Values must match."
            case .differs: "Value must be different."
            }
        }
    }
}

// MARK: - State

public extension FieldsValidator {

    /// A whole-form validation snapshot.
    struct State {
        /// `true` when every field satisfies every rule. Ignores touched-state.
        public let isValid: Bool
        /// Per-field state, keyed by field.
        public let fields: [Field: FieldState]
    }

    /// A single field's validation snapshot.
    struct FieldState {
        /// `true` when the field satisfies all of its rules. Ignores touched-state.
        public let isValid: Bool
        /// `true` once ``FieldsValidator/set(_:on:)`` has been called on the field.
        public let isTouched: Bool
        /// Failing rules with their resolved messages. Empty unless the field is touched.
        public let errors: [Failure]

        /// The non-empty resolved messages joined by `"\n"`, or `nil` when there are none to show.
        public var message: String? {
            let joined = errors.map(\.message).filter { !$0.isEmpty }.joined(separator: "\n")
            return joined.isEmpty ? nil : joined
        }
    }

    /// A failing rule paired with its resolved message.
    struct Failure {
        public let rule: Rule
        public let message: String
    }
}
