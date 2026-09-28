//
//  UIViewController+SetupAsKeyboardDismissable.swift
//

import UIKit

extension UIViewController {

    /// Configures the view to dismiss the keyboard on tap.
    ///
    /// A tap outside controls ends editing and still reaches what is under it: cell and row selection, pickers and the
    /// view's own `onTap` handler keep working, and a later `view.onTap` doesn't replace the dismissal. A tap on a
    /// control or a text input is left to it: a button keeps the keyboard up, and tapping another field moves the
    /// focus. Calling it more than once installs one recognizer.
    public func setupAsKeyboardDismissable() {
        guard !(view.gestureRecognizers?.contains { $0 is KeyboardDismissTapGestureRecognizer } ?? false) else { return }
        view.addGestureRecognizer(KeyboardDismissTapGestureRecognizer(viewController: self))
    }
}

// MARK: - KeyboardDismissTapGestureRecognizer

/// Ends editing on a tap without taking the tap away from the view hierarchy: it doesn't cancel the touches, and it
/// recognizes alongside every other recognizer. Taps on controls and text inputs are left to them, as UIKit does for
/// any parent tap recognizer. It holds its view controller weakly.
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

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        KeyboardDismissTapGestureRecognizer.endsEditing(forTapOn: touch.view, in: view)
    }

    /// Whether a tap on `touchedView` ends editing: not when it lands on, or inside, a control (a button, a text
    /// field) or a text view. Otherwise tapping another field would end editing instead of moving the focus.
    static func endsEditing(forTapOn touchedView: UIView?, in root: UIView?) -> Bool {
        var current = touchedView
        while let view = current, view !== root {
            if view is UIControl || view is UITextView { return false }
            current = view.superview
        }
        return true
    }
}
