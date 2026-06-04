//
//  FieldsValidatorTests.swift
//

import XCTest
@testable import Common

// MARK: - Test field key

private enum Field: Hashable {
    case name
    case email
    case rut
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
        XCTAssertEqual(validator.state.fields[.name]?.isValid, true)
        XCTAssertEqual(validator.state.fields[.email]?.isValid, true)
    }

    func test_fieldWithoutRules_isAbsentAndDoesNotAffectValidity() {
        let validator = Validator(rules: [.name: [.notEmpty]]) { _ in }
        validator.set("Jane", on: .name)

        XCTAssertNil(validator.state.fields[.email], "Undeclared fields are not part of the state")
        XCTAssertTrue(validator.state.isValid)
    }

    // MARK: Value assignment and nil handling

    func test_clearingRequiredField_withNil_refailsIt() {
        let validator = Validator(rules: [.name: [.notEmpty]]) { _ in }

        validator.set("Jane", on: .name)
        XCTAssertTrue(validator.state.isValid)

        validator.set(nil, on: .name) // nil is treated as "", not a removal
        XCTAssertFalse(validator.state.isValid)
    }

    // MARK: Cross-field rules

    func test_matches_passesWhenEqual_failsWhenNot() {
        let validator = Validator(rules: [
            .password: [.notEmpty],
            .confirmPassword: [.matches(.password)]
        ]) { _ in }

        validator.set("secret1", on: .password)
        validator.set("secret1", on: .confirmPassword)
        XCTAssertEqual(validator.state.fields[.confirmPassword]?.isValid, true)

        validator.set("secret2", on: .confirmPassword)
        XCTAssertEqual(validator.state.fields[.confirmPassword]?.isValid, false)
    }

    func test_matches_reEvaluatesWhenReferencedFieldEdited() {
        let validator = Validator(rules: [
            .password: [.notEmpty],
            .confirmPassword: [.matches(.password)]
        ]) { _ in }

        validator.set("secret1", on: .password)
        validator.set("secret1", on: .confirmPassword)
        XCTAssertEqual(validator.state.fields[.confirmPassword]?.isValid, true)

        validator.set("changed", on: .password) // editing the reference re-checks the dependent
        XCTAssertEqual(validator.state.fields[.confirmPassword]?.isValid, false)
    }

    func test_differs_passesWhenDifferent_andReEvaluates() {
        let validator = Validator(rules: [
            .currentPassword: [.notEmpty],
            .password: [.differs(from: .currentPassword)]
        ]) { _ in }

        validator.set("oldPass", on: .currentPassword)
        validator.set("newPass", on: .password)
        XCTAssertEqual(validator.state.fields[.password]?.isValid, true)

        validator.set("newPass", on: .currentPassword) // now identical → must fail
        XCTAssertEqual(validator.state.fields[.password]?.isValid, false)
    }

    // MARK: Touched-state gates error display

    func test_untouchedInvalidField_hidesErrors_butStaysInvalid() {
        let validator = Validator(rules: [.email: [.notEmpty, .email]]) { _ in }

        let field = validator.state.fields[.email]
        XCTAssertEqual(field?.errors.isEmpty, true)
        XCTAssertNil(field?.message)
        XCTAssertEqual(field?.isValid, false)
    }

    func test_touchedInvalidField_surfacesFailingRules() {
        let validator = Validator(rules: [.password: [.notEmpty, .minLength(6)]]) { _ in }

        validator.set("abc", on: .password)

        let field = validator.state.fields[.password]
        XCTAssertEqual(field?.errors.map(\.rule), [.minLength(6)])
        XCTAssertNotNil(field?.message)
    }

    func test_touchAll_revealsErrorsOnUntouchedFields() {
        let validator = Validator(rules: [
            .name: [.notEmpty],
            .email: [.notEmpty, .email]
        ]) { _ in }

        XCTAssertNil(validator.state.fields[.name]?.message)

        validator.touchAll()

        XCTAssertNotNil(validator.state.fields[.name]?.message)
        XCTAssertNotNil(validator.state.fields[.email]?.message)
    }

    // MARK: Message resolution

    func test_resolverOverride_winsOverDefault() {
        let validator = Validator(
            rules: [.email: [.notEmpty, .email]],
            message: { _, rule in rule == .email ? "Enter a valid email address" : rule.defaultMessage }
        ) { _ in }

        validator.set("abc", on: .email)

        XCTAssertEqual(validator.state.fields[.email]?.message, "Enter a valid email address")
    }

    func test_defaultMessage_usedWhenNoResolver() {
        let validator = Validator(rules: [.name: [.notEmpty]]) { _ in }

        validator.set("", on: .name)

        XCTAssertEqual(validator.state.fields[.name]?.message, "This field is required.")
    }

    func test_emptyMessage_suppressesDisplay_butNotValidity() {
        let validator = Validator(
            rules: [.name: [.notEmpty]],
            message: { _, rule in rule == .notEmpty ? "" : rule.defaultMessage }
        ) { _ in }

        validator.set("", on: .name)

        XCTAssertNil(validator.state.fields[.name]?.message)            // hidden
        XCTAssertEqual(validator.state.fields[.name]?.isValid, false)   // still enforced
        XCTAssertFalse(validator.state.isValid)
    }

    func test_message_joinsOnlyNonEmptyFailures() {
        // notEmpty resolves to "" (suppressed); minLength resolves to text → only that shows.
        let validator = Validator(
            rules: [.password: [.notEmpty, .minLength(6)]],
            message: { _, rule in
                switch rule {
                case .notEmpty:         ""
                case .minLength(let n): "min \(n)"
                default:                rule.defaultMessage
                }
            }
        ) { _ in }

        validator.set("", on: .password) // both notEmpty and minLength fail
        XCTAssertEqual(validator.state.fields[.password]?.message, "min 6")
    }

    // MARK: Reactivity

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

    func test_onChange_deliversSameValidityAsStateProperty() {
        var delivered: Validator.State?
        let validator = Validator(rules: [.name: [.notEmpty]]) { delivered = $0 }

        validator.set("Jane", on: .name)

        XCTAssertEqual(delivered?.isValid, validator.state.isValid)
    }

    // MARK: Built-in rule semantics

    func test_lengthRules_boundariesAreInclusive() {
        let validator = Validator(rules: [.password: [.minLength(8), .maxLength(10)]]) { _ in }

        validator.set("12345678", on: .password)     // 8 — lower bound
        XCTAssertEqual(validator.state.fields[.password]?.isValid, true)
        validator.set("1234567890", on: .password)   // 10 — upper bound
        XCTAssertEqual(validator.state.fields[.password]?.isValid, true)
        validator.set("1234567", on: .password)      // 7 — below min
        XCTAssertEqual(validator.state.fields[.password]?.isValid, false)
        validator.set("12345678901", on: .password)  // 11 — above max
        XCTAssertEqual(validator.state.fields[.password]?.isValid, false)
    }

    func test_characterClassRules() {
        assertRule(.containsLetter,    passes: "abc",  fails: "123")
        assertRule(.containsNumber,    passes: "abc1", fails: "abc")
        assertRule(.containsLowercase, passes: "Abc",  fails: "ABC")
        assertRule(.containsUppercase, passes: "aBc",  fails: "abc")
        assertRule(.contains(CharacterSet(charactersIn: "@")), passes: "x@y", fails: "xy")
    }

    func test_email_usesCommonExtension() {
        assertRule(.email, passes: "jane@example.com", fails: "not-an-email")
    }

    func test_rut_usesCommonExtension() {
        assertRule(.rut, passes: "12.345.678-5", fails: "12.345.678-0")
    }

    // MARK: Helpers

    /// Asserts a single-value rule passes for `valid` and fails for `invalid`.
    private func assertRule(
        _ rule: Validator.Rule,
        passes valid: String,
        fails invalid: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let validator = Validator(rules: [.name: [rule]]) { _ in }

        validator.set(valid, on: .name)
        XCTAssertEqual(validator.state.fields[.name]?.isValid, true,
                       "\(rule) should pass for \"\(valid)\"", file: file, line: line)

        validator.set(invalid, on: .name)
        XCTAssertEqual(validator.state.fields[.name]?.isValid, false,
                       "\(rule) should fail for \"\(invalid)\"", file: file, line: line)
    }
}
