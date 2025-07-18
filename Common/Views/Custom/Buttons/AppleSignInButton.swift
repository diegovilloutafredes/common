//
//  AppleSignInButton.swift
//

import AuthenticationServices
import UIKit

final class AppleSignInButton: UIButton {
    private let authButtonStyle = ASAuthorizationAppleIDButton.Style.white.rawValue
    private let authButtonType = ASAuthorizationAppleIDButton.ButtonType.default.rawValue
    private let cornerRadius: CGFloat = .DefaultValues.Button.cornerRadius

    private var authorizationButton: ASAuthorizationAppleIDButton! {
        didSet {
            authorizationButton.addTarget(self, action: #selector(authorizationAppleIDButtonTapped(_:)), for: .touchUpInside)
        }
    }

    override public func draw(_ rect: CGRect) {
        super.draw(rect)

        let type = ASAuthorizationAppleIDButton.ButtonType(rawValue: authButtonType) ?? .default
        let style = ASAuthorizationAppleIDButton.Style(rawValue: authButtonStyle) ?? .white

        authorizationButton = ASAuthorizationAppleIDButton(authorizationButtonType: type, authorizationButtonStyle: style)
        authorizationButton.cornerRadius = cornerRadius

        addSubview(authorizationButton)

        authorizationButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [
                authorizationButton.topAnchor.constraint(equalTo: topAnchor, constant: .zero),
                authorizationButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .zero),
                authorizationButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: .zero),
                authorizationButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: .zero)
            ]
        )
    }

    @objc func authorizationAppleIDButtonTapped(_ sender: Any) { sendActions(for: .touchUpInside) }
}
