//
//  ActivityIndicatorable.swift
//

import UIKit

nonisolated(unsafe) private var stashedRightViewKey: UInt8 = 0
nonisolated(unsafe) private var stashedRightViewModeKey: UInt8 = 0
nonisolated(unsafe) private var preHiddenSubviewsKey: UInt8 = 0

// MARK: - ActivityIndicatorable
/// A protocol for objects that can manage the visibility and state of an activity indicator.
@MainActor
public protocol ActivityIndicatorable: AnyObject {
    
    /// Starts the activity indicator with the default color.
    func startActivityIndicator()
    
    /// Starts the activity indicator with a specific color.
    /// - Parameter color: The color to apply to the activity indicator.
    func startActivityIndicator(with color: UIColor)
    
    /// Stops the activity indicator.
    func stopActivityIndicator()
}

// MARK: - where Self: BaseCoordinator
extension ActivityIndicatorable where Self: BaseCoordinator {
    private var activityIndicatorable: ActivityIndicatorable? { navigationController.topViewController }
    public func startActivityIndicator() { activityIndicatorable?.startActivityIndicator() }
    public func startActivityIndicator(with color: UIColor) { activityIndicatorable?.startActivityIndicator(with: color) }
    public func stopActivityIndicator() { activityIndicatorable?.stopActivityIndicator() }
}

// MARK: - where Self: UITextField
extension ActivityIndicatorable where Self: UITextField {
    public func startActivityIndicator() { startActivityIndicator(with: textColor ?? backgroundColor?.inverted ?? .black) }

    public func startActivityIndicator(with color: UIColor) {
        let activityIndicator = UIActivityIndicatorView()
            .color(color)
            .animate()
            .with { $0.sizeToFit() }

        // Stash the current rightView/rightViewMode so stop can restore them.
        // On a double-start the spinner is already installed — keep the original stash.
        if !(rightView is UIActivityIndicatorView) {
            objc_setAssociatedObject(self, &stashedRightViewKey, rightView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            objc_setAssociatedObject(self, &stashedRightViewModeKey, rightViewMode.rawValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }

        rightView(activityIndicator)
    }

    public func stopActivityIndicator() {
        guard let activityIndicator = rightView as? UIActivityIndicatorView else { return }
        activityIndicator.stopAnimating()

        rightView = objc_getAssociatedObject(self, &stashedRightViewKey) as? UIView
        if
            let rawMode = objc_getAssociatedObject(self, &stashedRightViewModeKey) as? Int,
            let mode = UITextField.ViewMode(rawValue: rawMode) {
            rightViewMode = mode
        }

        objc_setAssociatedObject(self, &stashedRightViewKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &stashedRightViewModeKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

// MARK: - where Self: UIView
extension ActivityIndicatorable where Self: UIView {
    public func startActivityIndicator() {
        dispatchOnMain { [weak self] in guard let self else { return }; startActivityIndicator(with: backgroundColor?.inverted ?? .black) }
    }

    public func startActivityIndicator(with color: UIColor) {
        let activityIndicator = UIActivityIndicatorView()
            .color(color)
            .with { $0.sizeToFit() }
            .setConstraints { $0.alignCenter(with: $1) }

        defer { activityIndicator.startAnimating() }

        // Record which subviews were already hidden so stop restores exactly that
        // state. On a double-start the record already exists — keep the original.
        if objc_getAssociatedObject(self, &preHiddenSubviewsKey) == nil {
            let preHidden = NSHashTable<UIView>.weakObjects()
            subviews
                .filter { $0.isHidden && !($0 is UIActivityIndicatorView) }
                .forEach { preHidden.add($0) }
            objc_setAssociatedObject(self, &preHiddenSubviewsKey, preHidden, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }

        subviews
            .forEach {
                ($0 as? UIActivityIndicatorView)?.removeFromSuperview()
                $0.hide(animated: false)
            }

        subviews { activityIndicator }
    }

    public func stopActivityIndicator() {
        dispatchOnMain { [weak self] in guard let self else { return }
            let preHidden = objc_getAssociatedObject(self, &preHiddenSubviewsKey) as? NSHashTable<UIView>

            // Never started: nothing to restore, don't disturb subview state.
            guard preHidden != nil || subviews.contains(where: { $0 is UIActivityIndicatorView })
            else { return }

            subviews
                .filter { !(preHidden?.contains($0) ?? false) }
                .forEach { $0.show(animated: false) }

            subviews
                .compactMap { $0 as? UIActivityIndicatorView }
                .forEach {
                    $0.stopAnimating()
                    $0.removeFromSuperview()
                }

            objc_setAssociatedObject(self, &preHiddenSubviewsKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

// MARK: - where Self: UIViewController
extension ActivityIndicatorable where Self: UIViewController {
    public func startActivityIndicator() {
        dispatchOnMain { [weak self] in guard let self else { return }
            var color: UIColor {
                navigationController?.navigationBar.backgroundColor?.inverted ??
                navigationController?.navigationBar.titleColor ??
                .black
            }

            startActivityIndicator(with: color)
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
                let nc = navigationController,
                !nc.isNavigationBarHidden
            else {
                view
                    .subviews
                    .compactMap { $0 as? UIActivityIndicatorView }
                    .forEach {
                        $0.stopAnimating()
                        $0.removeFromSuperview()
                    }
                return
            }

            navigationItem
                .rightBarButtonItems?
                .compactMap { $0.customView as? UIActivityIndicatorView }
                .forEach { $0.stopAnimating() }

            let itemsToAdd = navigationItem.rightBarButtonItems?.filter { !($0.customView is UIActivityIndicatorView) }
            navigationItem.setRightBarButtonItems(itemsToAdd, animated: true)
        }
    }
}
