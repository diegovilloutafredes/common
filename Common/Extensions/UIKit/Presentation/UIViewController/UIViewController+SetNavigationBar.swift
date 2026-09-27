//
//  UIViewController+SetNavigationBar.swift
//

import UIKit

// MARK: - UIViewController Extension
extension UIViewController {
    
    /// Styles this screen's navigation bar.
    ///
    /// The style is stored in the screen's own `navigationItem` appearances, so it applies while this screen is on top
    /// and never leaks onto the other screens in the stack. Call it on every screen that needs the style, or style the
    /// navigation controller's bar once for all of them. It can be called before the screen is pushed.
    /// - Parameters:
    ///   - backgroundColor: The background color of the navigation bar.
    ///   - titleColor: The color of the navigation bar title.
    ///   - titleFont: The font of the navigation bar title.
    ///   - largeTitleFont: The font to use for large titles.
    ///   - leftBarButtonItemTintColor: The tint color for the left bar button item.
    ///   - rightBarButtonItemTintColor: The tint color for the right bar button item.
    ///   - barButtonItemFont: The font for bar button items.
    ///   - hasShadow: Whether the navigation bar shows the system's bar shadow (the hairline an opaque bar draws).
    ///     Defaults to `false`.
    ///   - isTranslucent: Whether the navigation controller's bar is translucent. UIKit has no per-screen setting for
    ///     this, so unlike the other options it changes the shared bar, for every screen in the stack.
    public func setNavigationBar(
        backgroundColor: UIColor? = nil,
        titleColor: UIColor = .black,
        titleFont: UIFont = .systemFont(ofSize: 16),
        largeTitleFont: UIFont = .systemFont(ofSize: 28),
        leftBarButtonItemTintColor: UIColor? = .black,
        rightBarButtonItemTintColor: UIColor? = .black,
        barButtonItemFont: UIFont? = nil,
        hasShadow: Bool = false,
        isTranslucent: Bool = true
    ) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = backgroundColor
        // The transparent configuration carries no shadow; an opaque one carries the system's bar hairline.
        appearance.shadowColor = hasShadow ? UINavigationBarAppearance().with { $0.configureWithOpaqueBackground() }.shadowColor : nil

        appearance.titleTextAttributes = [
            .font: titleFont,
            .foregroundColor: titleColor
        ]

        appearance.largeTitleTextAttributes = [
            .font: largeTitleFont,
            .foregroundColor: titleColor
        ]

        // The item's appearance properties copy on assignment.
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationItem.compactScrollEdgeAppearance = appearance

        navigationController?.navigationBar.isTranslucent = isTranslucent

        navigationItem.leftBarButtonItems?
            .compactMap { $0 }
            .forEach {
                $0.tintColor = leftBarButtonItemTintColor

                if let barButtonItemFont = barButtonItemFont {
                    $0.setTitleTextAttributes(
                        [.font: barButtonItemFont],
                        for: .normal
                    )
                }
            }

        navigationItem.rightBarButtonItems?
            .compactMap { $0 }
            .forEach {
                $0.tintColor = rightBarButtonItemTintColor

                if let barButtonItemFont = barButtonItemFont {
                    $0.setTitleTextAttributes(
                        [.font: barButtonItemFont],
                        for: .normal
                    )
                }
            }
    }
}
