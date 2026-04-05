//
//  UIViewController+SetNavigationBar.swift
//

import UIKit

// MARK: - UIViewController Extension
// MARK: - UIViewController Extension
extension UIViewController {
    
    /// Configures the navigation bar with specific styles and attributes.
    /// - Parameters:
    ///   - backgroundColor: The background color of the navigation bar.
    ///   - titleColor: The color of the navigation bar title.
    ///   - titleFont: The font of the navigation bar title.
    ///   - largeTitleFont: The font to use for large titles.
    ///   - leftBarButtonItemTintColor: The tint color for the left bar button item.
    ///   - rightBarButtonItemTintColor: The tint color for the right bar button item.
    ///   - barButtonItemFont: The font for bar button items.
    ///   - hasShadow: Whether the navigation bar shows a shadow.
    ///   - isTranslucent: Whether the navigation bar is translucent.
    public func setNavigationBar(
        backgroundColor: UIColor? = nil,
        titleColor: UIColor = .black,
        titleFont: UIFont = .systemFont(ofSize: 16),
        largeTitleFont: UIFont = .systemFont(ofSize: 28),
        leftBarButtonItemTintColor: UIColor? = .black,
        rightBarButtonItemTintColor: UIColor? = .black,
        barButtonItemFont: UIFont? = nil,
        hasShadow: Bool = true,
        isTranslucent: Bool = true
    ) {
        guard let navigationBar = navigationController?.navigationBar else { return }

        let standardAppearance = UINavigationBarAppearance()
        standardAppearance.configureWithTransparentBackground()
        standardAppearance.backgroundColor = backgroundColor

        if !hasShadow { standardAppearance.shadowColor = nil }

        standardAppearance.titleTextAttributes = [
            .font: titleFont,
            .foregroundColor: titleColor
        ]

        standardAppearance.largeTitleTextAttributes = [
            .font: largeTitleFont,
            .foregroundColor: titleColor
        ]

        let compactAppearance = standardAppearance.copy()

        navigationBar.standardAppearance = standardAppearance
        navigationBar.scrollEdgeAppearance = standardAppearance
        navigationBar.compactAppearance = compactAppearance

        if #available(iOS 15.0, *) {
            navigationBar.compactScrollEdgeAppearance = compactAppearance
        }

        navigationBar.isTranslucent = isTranslucent

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
