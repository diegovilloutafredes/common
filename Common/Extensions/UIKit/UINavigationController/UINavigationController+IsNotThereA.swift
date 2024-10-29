//
//  UINavigationController+IsNotThereA.swift
//

import UIKit

extension UINavigationController {
    public func isNotThereA<T>(_ type: T.Type) -> Bool { !isThereA(type) }
}
