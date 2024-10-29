//
//  UITapGestureRecognizer+NumberOfTapsRequired.swift
//

import UIKit

extension UITapGestureRecognizer {
    @discardableResult public func numberOfTapsRequired(_ numberOfTapsRequired: Int) -> Self {
        with { $0.numberOfTapsRequired = numberOfTapsRequired }
    }
}
