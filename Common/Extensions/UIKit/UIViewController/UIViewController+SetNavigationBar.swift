//
//  UIViewController+SetNavigationBar.swift
//

import UIKit

// MARK: - UIViewController Extension
extension UIViewController {
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
