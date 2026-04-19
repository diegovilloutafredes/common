//
//  FormsViewController.swift
//  DemoApp
//

import Common
import UIKit

// MARK: - FormsViewController
final class FormsViewController: BaseViewModelableViewController<FormsViewModelProtocol> {

    private lazy var nameField = makeTextField(
        placeholder: "Full Name",
        contentType: .name,
        keyboardType: .default
    )
    .onEditingChanged { [weak self] field in
        self?.viewModel.validate(field: .name, value: field.text ?? "")
    }
    .onReturnKeyPressed { [weak self] _ in
        self?.emailField.becomeFirstResponder()
    }

    private lazy var emailField = makeTextField(
        placeholder: "Email Address",
        contentType: .emailAddress,
        keyboardType: .emailAddress
    )
    .onEditingChanged { [weak self] field in
        self?.viewModel.validate(field: .email, value: field.text ?? "")
    }
    .onReturnKeyPressed { [weak self] _ in
        self?.passwordField.becomeFirstResponder()
    }

    private lazy var passwordField = makeTextField(
        placeholder: "Password (min 6 chars)",
        contentType: .password,
        keyboardType: .default
    )
    .isSecureTextEntry(true)
    .addToggleVisibilityButton()
    .onEditingChanged { [weak self] field in
        self?.viewModel.validate(field: .password, value: field.text ?? "")
    }
    .onReturnKeyPressed { [weak self] _ in
        self?.view.endEditing(true)
    }

    private lazy var nameErrorLabel = makeErrorLabel()
    private lazy var emailErrorLabel = makeErrorLabel()
    private lazy var passwordErrorLabel = makeErrorLabel()

    private lazy var submitButton = UIButton(
        configuration: .filled()
            .with {
                $0.attributedTitle = .init(
                    "Submit",
                    attributes: .init()
                        .with { $0.font = .boldSystemFont(ofSize: 16) }
                )
                $0.baseBackgroundColor = .systemBlue
                $0.baseForegroundColor = .white
                $0.cornerStyle = .capsule
            }
    )
    .isEnabled(false)
    .onTap { [weak self] in self?.onSubmit() }
    .setConstraints { $0.set(height: 50) }

    @UIViewBuilder
    override var mainView: UIView {
        VStack(
            margins: .init(top: 32, left: 24, bottom: 32, right: 24),
            spacing: 24
        ) {
            VStack(spacing: 16) {
                VStack(spacing: 4) { nameField; nameErrorLabel }
                VStack(spacing: 4) { emailField; emailErrorLabel }
                VStack(spacing: 4) { passwordField; passwordErrorLabel }
            }

            submitButton

            VStack(
                margins: .init(top: 12, left: 12, bottom: 12, right: 12),
                spacing: 8
            ) {
                HStack(alignment: .center, spacing: 6) {
                    UIImageView(image: .init(systemName: "info.circle.fill"))
                        .tintColor(.systemBlue)
                        .contentMode(.scaleAspectFit)
                        .setConstraints { $0.set(width: 18); $0.set(height: 18) }
                    UILabel()
                        .text("This module demonstrates:")
                        .font(.boldSystemFont(ofSize: 14))
                        .textColor(.label)
                }
                UILabel()
                    .text("• TextField chaining (.borderColor, .placeholder, .onEditingChanged)\n• Field validation with error labels\n• Keyboard-aware layout (pinBottom to keyboardLayoutGuide)\n• Secure text entry with visibility toggle\n• Return key navigation between fields")
                    .font(.systemFont(ofSize: 13))
                    .textColor(.secondaryLabel)
                    .numberOfLines(0)
            }
            .backgroundColor(.secondarySystemBackground)
            .round(radius: 12)
        }
        .setConstraints {
            $0.snapLeadTopTrail(to: $1.safeAreaLayoutGuide)
            $0.pinBottom(to: $1.keyboardLayoutGuide.topAnchor)
        }
    }

    override func setupView() {
        super.setupView()
        title = viewModel.title
        view.backgroundColor(.systemBackground)
        view.onTap { [weak self] _, _ in self?.view.endEditing(true) }
    }

    private func onSubmit() {
        view.endEditing(true)
        viewModel.submit(
            name: nameField.text ?? "",
            email: emailField.text ?? "",
            password: passwordField.text ?? ""
        )
    }
}

// MARK: - Factory
extension FormsViewController {
    private func makeTextField(
        placeholder: String,
        contentType: UITextContentType,
        keyboardType: UIKeyboardType
    ) -> UITextField {
        UITextField()
            .borderColor(.systemGray3)
            .borderWidth(1)
            .font(.systemFont(ofSize: 16))
            .textColor(.label)
            .placeholder(placeholder, color: .systemGray2, font: .systemFont(ofSize: 16))
            .contentType(contentType)
            .keyboardType(keyboardType)
            .setAsRoundedView(radius: 8)
            .setConstraints { $0.set(height: 50) }
            .with { $0.leftView = UIView(frame: .init(x: 0, y: 0, width: 12, height: 0)); $0.leftViewMode = .always }
    }

    private func makeErrorLabel() -> UILabel {
        UILabel()
            .font(.systemFont(ofSize: 12))
            .textColor(.systemRed)
            .numberOfLines(1)
            .isHidden(true)
    }
}

// MARK: - FormsViewProtocol
extension FormsViewController: FormsViewProtocol {
    func updateValidationStatus(isValid: Bool) {
        submitButton.isEnabled(isValid)
    }

    func showFieldError(field: FormsViewModel.Field, message: String) {
        errorLabel(for: field).text(message).isHidden(false)
        textField(for: field).borderColor(.systemRed)
    }

    func clearFieldError(field: FormsViewModel.Field) {
        errorLabel(for: field).isHidden(true)
        textField(for: field).borderColor(.systemGray3)
    }

    private func errorLabel(for field: FormsViewModel.Field) -> UILabel {
        switch field {
        case .name: nameErrorLabel
        case .email: emailErrorLabel
        case .password: passwordErrorLabel
        }
    }

    private func textField(for field: FormsViewModel.Field) -> UITextField {
        switch field {
        case .name: nameField
        case .email: emailField
        case .password: passwordField
        }
    }
}
