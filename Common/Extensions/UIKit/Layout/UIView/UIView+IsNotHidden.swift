//
//  UIView+IsNotHidden.swift
//

import UIKit

extension UIView {
    
    /// Returns `true` if the view is not hidden.
    public var isNotHidden: Bool { !isHidden }
}
