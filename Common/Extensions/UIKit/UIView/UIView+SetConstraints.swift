//
//  UIView+SetConstraints.swift
//

import UIKit

// MARK: - Set Constraints
extension UIView {
    @discardableResult public func setConstraints(_ setConstraints: @escaping ViewHandler) -> Self { onMoveToSuperview(setConstraints) }
    @discardableResult public func setConstraints(_ setConstraints: @escaping ViewAndSuperviewHandler) -> Self { onMoveToSuperview(setConstraints) }
}
