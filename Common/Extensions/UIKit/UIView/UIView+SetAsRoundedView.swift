//
//  UIView+SetAsRoundedView.swift
//

import UIKit

// MARK: - Set as rounded view
extension UIView {
    @discardableResult public func setAsRoundedView(using maskedCorners: CACornerMask = .all, radius: CGFloat? = nil, animated: Bool = false) -> Self {
        with { _ in
            dispatchOnMain { [weak self] in guard let self else { return }
                self.clipsToBounds(true)

                let actions: CompletionHandler = {
                    self.round(corners: maskedCorners, radius: radius ?? self.frame.height / 2)
                }

                guard animated else {
                    actions?()
                    return
                }

                UIView.animate(
                    withDuration: .DefaultValues.animationDuration,
                    delay: .zero,
                    options: .curveEaseIn,
                    animations: { actions?() }
                )
            }
        }
    }
}
