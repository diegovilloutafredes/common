//
//  ActionButton.swift
//  DemoApp
//

import UIKit

// MARK: - ButtonTheme
public protocol ButtonTheme {
    var backgroundColor: UIColor { get }
    var borderColor: UIColor { get }
    var borderWidth: Double { get }
    var titleColor: UIColor { get }
    var titleFont: UIFont { get }
}

// MARK: - DefaultButtonTheme
public enum DefaultButtonTheme {
    case filled
    case border
}

// MARK: - ButtonTheme
extension DefaultButtonTheme: ButtonTheme {
    public var backgroundColor: UIColor {
        switch self {
        case .filled: .black
        case .border: .white
        }
    }

    public var borderColor: UIColor {
        switch self {
        case .filled: backgroundColor
        case .border: .black
        }
    }

    public var borderWidth: Double {
        switch self {
        case .filled: .zero
        case .border: 1
        }
    }

    public var titleColor: UIColor {
        switch self {
        case .filled: .white
        case .border: .black
        }
    }

    public var titleFont: UIFont { .systemFont(ofSize: 14) }
}

// MARK: - ActionButton
public final class ActionButton: BaseButton {
    private let shouldApplyDefaultRatio: Bool
    private let theme: ButtonTheme

    public init(_ title: String? = nil, isEnabled: Bool = true, shouldApplyDefaultRatio: Bool = true, theme: ButtonTheme = DefaultButtonTheme.filled) {
        self.shouldApplyDefaultRatio = shouldApplyDefaultRatio
        self.theme = theme
        super.init()
        self.title(title)
        set(isEnabled: isEnabled)
    }

    public override func setupView() {
        backgroundColor(theme.backgroundColor)
        .borderColor(theme.borderColor)
        .borderWidth(theme.borderWidth)
        .font(theme.titleFont)
        .setAsRoundedView()
        .titleColor(theme.titleColor)
        .with { if shouldApplyDefaultRatio { $0.setRatio(328/40) } }
    }
}

extension ActionButton {
    @discardableResult public func set(isEnabled: Bool) -> Self {
        with {
            $0
                .backgroundColor(isEnabled ? theme.backgroundColor : theme.backgroundColor.withAlphaComponent(0.3))
                .isEnabled(isEnabled)
        }
    }
}
