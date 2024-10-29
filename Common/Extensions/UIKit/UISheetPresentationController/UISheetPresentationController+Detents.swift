//
//  UISheetPresentationController+.swift
//

import UIKit

extension UISheetPresentationController {
    @discardableResult public func detents(_ detents: [Detent]) -> Self { with { $0.detents = detents } }
}
