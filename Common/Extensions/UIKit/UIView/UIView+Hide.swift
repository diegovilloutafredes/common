//
//  UIView+Hide.swift
//

import UIKit

// MARK: - Hide
extension UIView {
    public func hide(animated: Bool = true, with duration: TimeInterval = .DefaultValues.animationDuration, completion: CompletionHandler = nil) {
        guard isNotHidden else { return }

        guard animated else {
            alpha(.zero)
            isHidden = !animated
            completion?()
            return
        }

        dispatchOnMain { [weak self] in guard let self else { return }
            UIView.animate(
                withDuration: duration,
                delay: .zero,
                options: .curveEaseIn,
                animations: { self.alpha(.zero) }
            ) { _ in
                self.isHidden = animated
                completion?()
            }
        }
    }
}
