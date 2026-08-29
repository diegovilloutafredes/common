//
//  AppleSignInButton.swift
//

import AuthenticationServices
import UIKit

// MARK: - AppleSignInButton
/// A `UIButton`-shaped wrapper around `ASAuthorizationAppleIDButton`.
///
/// The inner Apple button's tap is re-emitted as `.touchUpInside`, so `.onTap { }`
/// and target-action both work, and `isEnabled`, the accessibility label and the
/// intrinsic size behave as they would on a plain button. Pair it with
/// ``AppleLoginManager/performLogin(from:result:)`` to run the flow:
///
/// ```swift
/// AppleSignInButton()                       // adaptive: black on light, white on dark
///     .onTap { [weak self] in self?.signIn() }
///
/// AppleSignInButton(type: .continue, style: .whiteOutline)
/// ```
///
/// Apple's button style is fixed at creation, so ``Style/adaptive`` rebuilds the
/// inner button when the interface style changes.
public final class AppleSignInButton: UIButton {

    // MARK: - Style
    /// The visual style of the button.
    public enum Style {
        /// Black button — for light backgrounds.
        case black
        /// White button — for dark backgrounds.
        case white
        /// White button with a black outline — for light backgrounds.
        case whiteOutline
        /// ``black`` in light appearance, ``white`` in dark appearance; follows
        /// interface-style changes.
        case adaptive
    }

    /// The Apple button type (Sign in / Continue / Sign up).
    public let authorizationButtonType: ASAuthorizationAppleIDButton.ButtonType
    /// The configured style.
    public let style: Style
    private let cornerRadius: CGFloat

    /// The Apple style currently applied to the inner button (test hook).
    private(set) var resolvedStyle: ASAuthorizationAppleIDButton.Style = .black
    private var innerButton: ASAuthorizationAppleIDButton?

    /// Creates a Sign in with Apple button.
    /// - Parameters:
    ///   - type: The Apple button type. Defaults to `.default` ("Sign in with Apple").
    ///   - style: The visual style. Defaults to ``Style/adaptive``.
    ///   - cornerRadius: The corner radius. Defaults to `.DefaultValues.Button.cornerRadius`.
    public init(
        type: ASAuthorizationAppleIDButton.ButtonType = .default,
        style: Style = .adaptive,
        cornerRadius: CGFloat = .DefaultValues.Button.cornerRadius
    ) {
        authorizationButtonType = type
        self.style = style
        self.cornerRadius = cornerRadius
        super.init(frame: .zero)
        // The wrapper is the accessibility element; VoiceOver reads the forwarded label.
        isAccessibilityElement = true
        resolvedStyle = resolveStyle()
        rebuildInnerButton()
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: AppleSignInButton, _: UITraitCollection) in
                self.updateStyleIfNeeded()
            }
        }
    }

    /// Creates a default (`.default` type, ``Style/adaptive``) button with the given frame.
    public override convenience init(frame: CGRect) {
        self.init(type: .default, style: .adaptive)
        self.frame = frame
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("NSCoder is not supported") }

    // MARK: - UIButton overrides

    public override var isEnabled: Bool {
        didSet { innerButton?.isEnabled = isEnabled }
    }

    public override var intrinsicContentSize: CGSize {
        innerButton?.intrinsicContentSize ?? super.intrinsicContentSize
    }

    /// Falls back to the inner Apple button's localized label ("Sign in with Apple", …).
    public override var accessibilityLabel: String? {
        get { super.accessibilityLabel ?? innerButton?.accessibilityLabel }
        set { super.accessibilityLabel = newValue }
    }

    // iOS 16 fallback — iOS 17+ uses the registered trait observation above.
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #unavailable(iOS 17.0),
           traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            updateStyleIfNeeded()
        }
    }

    // MARK: - Private

    private func resolveStyle() -> ASAuthorizationAppleIDButton.Style {
        switch style {
        case .black: .black
        case .white: .white
        case .whiteOutline: .whiteOutline
        case .adaptive: traitCollection.userInterfaceStyle == .dark ? .white : .black
        }
    }

    private func updateStyleIfNeeded() {
        let style = resolveStyle()
        guard style != resolvedStyle else { return }
        resolvedStyle = style
        rebuildInnerButton()
    }

    /// Apple's style is init-only, so a style change replaces the inner button.
    private func rebuildInnerButton() {
        innerButton?.removeFromSuperview()
        let button = ASAuthorizationAppleIDButton(authorizationButtonType: authorizationButtonType, authorizationButtonStyle: resolvedStyle)
        button.cornerRadius = cornerRadius
        button.isEnabled = isEnabled
        button.addTarget(self, action: #selector(innerButtonTapped), for: .touchUpInside)
        addSubview(button)
        button.snap(to: self)
        innerButton = button
        invalidateIntrinsicContentSize()
    }

    // `sendActions` does not consult `isEnabled`; gate the re-emission explicitly.
    @objc private func innerButtonTapped() {
        guard isEnabled else { return }
        sendActions(for: .touchUpInside)
    }
}
