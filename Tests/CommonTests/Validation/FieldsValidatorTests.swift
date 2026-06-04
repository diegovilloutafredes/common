//
//  FieldsValidatorTests.swift
//

import XCTest
@testable import Common

// MARK: - Test field key

private enum Field: Hashable {
    case name
    case email
    case password
    case confirmPassword
    case currentPassword
}

private typealias Validator = FieldsValidator<Field>

// MARK: - FieldsValidatorTests

@MainActor
final class FieldsValidatorTests: XCTestCase {

    // MARK: Declarative rules without placeholder seeding

    func test_untouchedRequiredField_isInvalid_withoutPlaceholder() {
        let validator = Validator(rules: [.email: [.notEmpty, .email]]) { _ in }
        XCTAssertFalse(validator.state.isValid)
    }

    func test_allRulesSatisfied_isValid() {
        let validator = Validator(rules: [
            .name: [.notEmpty, .minLength(2)],
            .email: [.notEmpty, .email]
        ]) { _ in }

        validator.set("Jane", on: .name)
        validator.set("jane@example.com", on: .email)

        XCTAssertTrue(validator.state.isValid)
        XCTAssertTrue(validator.state.fields[.name]?.isValid == true)
        XCTAssertTrue(validator.state.fields[.email]?.isValid == true)
    }

    // MARK: Value assignment and nil handling

    func test_clearingRequiredField_withNil_refailsIt() {
        let validator = Validator(rules: [.name: [.notEmpty]]) { _ in }

        validator.set("Jane", on: .name)
        XCTAssertTrue(validator.state.isValid)

        validator.set(nil, on: .name)
        XCTAssertFalse(validator.state.isValid)
    }

    // MARK: Declarative cross-field rules

    func test_matches_passesWhenConfirmationEqualsReference() {
        let validator = Validator(rules: [
            .password: [.notEmpty],
            .confirmPassword: [.matches(.password)]
        ]) { _ in }

        validator.set("secret1", on: .password)
        validator.set("secret1", on: .confirmPassword)

        XCTAssertTrue(validator.state.fields[.confirmPassword]?.isValid == true)
    }

    func test_editingReferencedField_reEvaluatesDependent() {
        let validator = Validator(rules: [
            .password: [.notEmpty],
            .confirmPassword: [.matches(.password)]
        ]) { _ in }

        validator.set("secret1", on: .password)
        validator.set("secret1", on: .confirmPassword)
        XCTAssertTrue(validator.state.fields[.confirmPassword]?.isValid == true)

        validator.set("secret2", on: .password)
        XCTAssertFalse(validator.state.fields[.confirmPassword]?.isValid == true)
    }

    func test_differsFrom_passesWhenValuesDiffer() {
        let validator = Validator(rules: [
            .currentPassword: [.notEmpty],
            .password: [.differs(from: .currentPassword)]
        ]) { _ in }

        validator.set("oldPass", on: .currentPassword)
        validator.set("newPass", on: .password)

        XCTAssertTrue(validator.state.fields[.password]?.isValid == true)
    }

    // MARK: Touched-state gates error display

    func test_untouchedInvalidField_showsNoErrors_butIsInvalid() {
        let validator = Validator(rules: [.email: [.notEmpty, .email]]) { _ in }

        let field = validator.state.fields[.email]
        XCTAssertEqual(field?.errors.isEmpty, true)
        XCTAssertNil(field?.message)
        XCTAssertEqual(field?.isValid, false)
    }

    func test_touchedInvalidField_surfacesErrors() {
        let validator = Validator(rules: [.password: [.notEmpty, .minLength(6)]]) { _ in }

        validator.set("abc", on: .password)

        let field = validator.state.fields[.password]
        XCTAssertTrue(field?.errors.contains { $0.rule == .minLength(6) } == true)
        XCTAssertNotNil(field?.message)
    }

    // MARK: Per-field-and-rule message resolution

    func test_resolverOverride_winsOverDefault() {
        let validator = Validator(
            rules: [.email: [.notEmpty, .email]],
            message: { _, rule in rule == .email ? "Enter a valid email address" : rule.defaultMessage }
        ) { _ in }

        validator.set("abc", on: .email)

        XCTAssertEqual(validator.state.fields[.email]?.message, "Enter a valid email address")
    }

    func test_emptyMessage_suppressesDisplay_butNotValidity() {
        let validator = Validator(
            rules: [.name: [.notEmpty]],
            message: { _, rule in rule == .notEmpty ? "" : rule.defaultMessage }
        ) { _ in }

        validator.set("", on: .name)

        XCTAssertNil(validator.state.fields[.name]?.message)
        XCTAssertFalse(validator.state.isValid)
    }

    func test_defaultMessage_usedWhenNoResolver() {
        let validator = Validator(rules: [.name: [.notEmpty]]) { _ in }

        validator.set("", on: .name)

        XCTAssertEqual(validator.state.fields[.name]?.message, "This field is required.")
    }

    // MARK: Single change notification per assignment

    func test_onChange_firesExactlyOncePerSet() {
        var fires = 0
        let validator = Validator(rules: [
            .name: [.notEmpty],
            .email: [.notEmpty, .email],
            .password: [.notEmpty, .minLength(6)],
            .confirmPassword: [.matches(.password)],
            .currentPassword: [.notEmpty]
        ]) { _ in fires += 1 }

        validator.set("Jane", on: .name)

        XCTAssertEqual(fires, 1)
    }

    // MARK: Built-in rule semantics

    func test_minLength_boundaryIsInclusive() {
        let validator = Validator(rules: [.password: [.minLength(8)]]) { _ in }

        validator.set("12345678", on: .password) // exactly 8
        XCTAssertTrue(validator.state.fields[.password]?.isValid == true)

        validator.set("1234567", on: .password) // 7
        XCTAssertFalse(validator.state.fields[.password]?.isValid == true)
    }

    func test_containsNumber_passesAndFails() {
        let validator = Validator(rules: [.password: [.containsNumber]]) { _ in }

        validator.set("abc1", on: .password)
        XCTAssertTrue(validator.state.fields[.password]?.isValid == true)

        validator.set("abc", on: .password)
        XCTAssertFalse(validator.state.fields[.password]?.isValid == true)
    }

    func test_email_usesCommonExtension() {
        let validator = Validator(rules: [.email: [.email]]) { _ in }

        validator.set("jane@example.com", on: .email)
        XCTAssertTrue(validator.state.fields[.email]?.isValid == true)

        validator.set("not-an-email", on: .email)
        XCTAssertFalse(validator.state.fields[.email]?.isValid == true)
    }

    // MARK: Reveal all errors on demand

    func test_touchAll_surfacesPendingErrors() {
        let validator = Validator(rules: [
            .name: [.notEmpty],
            .email: [.notEmpty, .email]
        ]) { _ in }

        // Nothing touched yet → no visible messages.
        XCTAssertNil(validator.state.fields[.name]?.message)
        XCTAssertNil(validator.state.fields[.email]?.message)

        validator.touchAll()

        XCTAssertNotNil(validator.state.fields[.name]?.message)
        XCTAssertNotNil(validator.state.fields[.email]?.message)
    }
}
