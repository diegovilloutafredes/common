//
//  UINavigationController+IsThereA.swift
//

import UIKit

extension UINavigationController {
    public func isThereA<T>(_ type: T.Type) -> Bool { viewControllers.contains { $0 is T } }
}
