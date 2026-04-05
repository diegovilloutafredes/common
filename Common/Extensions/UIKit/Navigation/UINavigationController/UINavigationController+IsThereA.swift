//
//  UINavigationController+IsThereA.swift
//

import UIKit

extension UINavigationController {
    
    /// Checks if the navigation stack contains a view controller of the specified type.
    /// - Parameter type: The type to check for.
    /// - Returns: `true` if a view controller of that type exists in the stack.
    public func isThereA<T>(_ type: T.Type) -> Bool { viewControllers.contains { $0 is T } }
}
