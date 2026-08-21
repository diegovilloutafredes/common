//
//  AppleSignInButton.swift
//

import AuthenticationServices
import UIKit

/// A wrapper around `ASAuthorizationAppleIDButton` to simplify its usage in UIKit.
///
/// Behaves as a plain `UIButton`: the inner Apple button's tap is re-emitted as
/// `.touchUpInside`, so `.onTap { }` and target-action both work. Pair with
/// `AppleLoginManager.performLogin(from:result:)` to run the flow.
public final class AppleSignInButton: UIButton {
    private let authButtonStyle = ASAuthorizationAppleIDButton.Style.white.rawValue
    private let authButtonType = ASAuthorizationAppleIDButton.ButtonType.default.rawValue
    private let cornerRadius: CGFloat = .DefaultValues.Button.cornerRadius

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupAuthorizationButton()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("NSCoder is not supported") }

    private func setupAuthorizationButton() {
        let type = ASAuthorizationAppleIDButton.ButtonType(rawValue: authButtonType) ?? .default
        let style = ASAuthorizationAppleIDButton.Style(rawValue: authButtonStyle) ?? .white
        let button = ASAuthorizationAppleIDButton(authorizationButtonType: type, authorizationButtonStyle: style)
        button.cornerRadius = cornerRadius
        button.addTarget(self, action: #selector(authorizationAppleIDButtonTapped(_:)), for: .touchUpInside)
        addSubview(button)
        button.snap(to: self)
    }

    @objc private func authorizationAppleIDButtonTapped(_ sender: Any) { sendActions(for: .touchUpInside) }
}
