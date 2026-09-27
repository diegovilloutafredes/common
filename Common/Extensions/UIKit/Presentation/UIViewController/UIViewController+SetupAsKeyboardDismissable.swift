//
//  UIViewController+SetupAsKeyboardDismissable.swift
//

import UIKit

extension UIViewController {

    /// Configures the view to dismiss the keyboard on tap.
    ///
    /// The tap still reaches what is under it: buttons, cells, pickers and the view's own `onTap` handler keep
    /// working, and a later `view.onTap` doesn't replace the dismissal. Calling it more than once installs one
    /// recognizer.
    public func setupAsKeyboardDismissable() {
        guard !(view.gestureRecognizers?.contains { $0 is KeyboardDismissTapGestureRecognizer } ?? false) else { return }
        view.addGestureRecognizer(KeyboardDismissTapGestureRecognizer(viewController: self))
    }
}

// MARK: - KeyboardDismissTapGestureRecognizer

/// Ends editing on a tap without taking the tap away from the view hierarchy: it doesn't cancel the touches, and it
/// recognizes alongside every other recognizer. It holds its view controller weakly.
final class KeyboardDismissTapGestureRecognizer: UITapGestureRecognizer, UIGestureRecognizerDelegate {
    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(recognized))
        cancelsTouchesInView = false
        delegate = self
    }

    @objc func recognized() { viewController?.dismissKeyboard() }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool { true }
}
