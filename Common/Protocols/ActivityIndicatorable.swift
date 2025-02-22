//
//  ActivityIndicatorable.swift
//

import UIKit

// MARK: - ActivityIndicatorable
public protocol ActivityIndicatorable: AnyObject {
    func startActivityIndicator()
    func startActivityIndicator(with color: UIColor)
    func stopActivityIndicator()
}

// MARK: - Default implementation where Self: BaseCoordinator
extension ActivityIndicatorable where Self: BaseCoordinator {
    private var activityIndicatorable: ActivityIndicatorable? { navigationController.topViewController }
    public func startActivityIndicator() { activityIndicatorable?.startActivityIndicator() }
    public func startActivityIndicator(with color: UIColor) { activityIndicatorable?.startActivityIndicator(with: color) }
    public func stopActivityIndicator() { activityIndicatorable?.stopActivityIndicator() }
}

// MARK: - Default implementation where Self: UITextField
extension ActivityIndicatorable where Self: UITextField {
    public func startActivityIndicator() { startActivityIndicator(with: textColor ?? .black) }

    public func startActivityIndicator(with color: UIColor) {
        let activityIndicator = UIActivityIndicatorView()
            .color(color)
            .animate()
            .with { $0.sizeToFit() }
        rightView(activityIndicator)
    }

    public func stopActivityIndicator() {
        guard let activityIndicator = rightView as? UIActivityIndicatorView else { return }
        activityIndicator.stopAnimating()
    }
}

// MARK: - Default implementation where Self: UIView
extension ActivityIndicatorable where Self: UIView {
    public func startActivityIndicator() {
        dispatchOnMain {
            var activityColor: UIColor { self.backgroundColor?.inverted ?? .black }
            self.startActivityIndicator(with: activityColor)
        }
    }

    public func startActivityIndicator(with color: UIColor) {
        let activityIndicator = UIActivityIndicatorView()
            .color(color)
            .with { $0.sizeToFit() }
            .setConstraints { $0.alignCenter(with: $1) }

        defer { activityIndicator.startAnimating() }

        subviews
            .forEach {
                ($0 as? UIActivityIndicatorView)?.removeFromSuperview()
                $0.hide(animated: false)
            }

        subviews { activityIndicator }
    }

    public func stopActivityIndicator() {
        dispatchOnMain { [weak self] in guard let self else { return }
            subviews.forEach { $0.show(animated: false) }
            subviews
                .compactMap { $0 as? UIActivityIndicatorView }
                .forEach {
                    $0.stopAnimating()
                    $0.removeFromSuperview()
                }
        }
    }
}

// MARK: - Default implementation where Self: UIViewController
extension ActivityIndicatorable where Self: UIViewController {
    public func startActivityIndicator() {
        dispatchOnMain {
            var activityColor: UIColor { self.navigationController?.navigationBar.backgroundColor?.inverted ?? self.navigationController?.navigationBar.titleColor ?? .black }
            self.startActivityIndicator(with: activityColor)
        }
    }

    public func startActivityIndicator(with color: UIColor) {
        let activityIndicator = UIActivityIndicatorView()
            .color(color)
            .with { $0.sizeToFit() }

        defer { activityIndicator.startAnimating() }

        guard
            let nc = navigationController,
            !nc.isNavigationBarHidden
        else {
            view
                .subviews
                .compactMap { $0 as? UIActivityIndicatorView }
                .forEach { $0.removeFromSuperview() }

            view.subviews { activityIndicator.setConstraints { $0.alignCenter(with: $1) } }

            return
        }

        let activityIndicatorAsBarButtonItem = UIBarButtonItem(customView: activityIndicator)

        guard
            navigationItem.rightBarButtonItems?.isEmpty ?? true
        else {
            var itemsToAdd = navigationItem
                .rightBarButtonItems?
                .filter { !($0.customView is UIActivityIndicatorView) }

            itemsToAdd?.append(activityIndicatorAsBarButtonItem)
            navigationItem.setRightBarButtonItems(itemsToAdd, animated: true)
            return
        }

        navigationItem.setRightBarButton(activityIndicatorAsBarButtonItem, animated: true)
    }

    public func stopActivityIndicator() {
        dispatchOnMain { [weak self] in guard let self else { return }
            guard
                let nc = self.navigationController,
                !nc.isNavigationBarHidden
            else {
                self.view
                    .subviews
                    .compactMap { $0 as? UIActivityIndicatorView }
                    .forEach {
                        $0.stopAnimating()
                        $0.removeFromSuperview()
                    }
                return
            }

            self.navigationItem
                .rightBarButtonItems?
                .compactMap { $0.customView as? UIActivityIndicatorView }
                .forEach { $0.stopAnimating() }

            let itemsToAdd = self.navigationItem.rightBarButtonItems?.filter { !($0.customView is UIActivityIndicatorView) }
            self.navigationItem.setRightBarButtonItems(itemsToAdd, animated: true)
        }
    }
}
