//
//  BackButtonAddable.swift
//

import UIKit

// MARK: - BackButtonAddable
public protocol BackButtonAddable: UIViewController {
    func addBackButton(_ icon: UIImage?, handler: CompletionHandler)
}

// MARK: - where Self: UIViewController
extension BackButtonAddable {
    public func addBackButton(_ icon: UIImage? = BackButtonAddableDefaultValues.icon, handler: CompletionHandler) { addBackButton(icon) { handler?() } }
}

extension UIViewController {
    public enum BackButtonAddableDefaultValues {
        public static var icon: UIImage? { .symbol("arrow.left") }
    }

    private var onBackButtonPressedHandler: Action? {
        get { associatedObject(for: "onBackButtonPressedHandler") as? Action }
        set { set(associatedObject: newValue, for: "onBackButtonPressedHandler") }
    }

    @discardableResult public func addBackButton(_ icon: UIImage? = BackButtonAddableDefaultValues.icon, action: @escaping Action) -> Self {
        with {
            $0.onBackButtonPressedHandler = action
            let leftBarButtonItem = UIBarButtonItem(
                image: icon,
                style: .plain,
                target: $0,
                action: #selector(onBackButtonPressed)
            )
            $0.navigationItem.setLeftBarButton(leftBarButtonItem, animated: false)
        }
    }

    @objc private func onBackButtonPressed() { onBackButtonPressedHandler?() }
}
