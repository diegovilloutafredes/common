//
//  UINavigationController+IsNotThereA.swift
//

import UIKit

extension UINavigationController {
    
    /// Checks if the navigation stack does not contain a view controller of the specified type.
    /// - Parameter type: The type to check for.
    /// - Returns: `true` if no view controller of that type exists in the stack.
    public func isNotThereA<T>(_ type: T.Type) -> Bool { !isThereA(type) }
}
