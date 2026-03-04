//
//  NSObject+ExtensionsStoredProperties.swift
//

import Foundation

/// Allows extensions to have stored properties
extension NSObject {
    private struct Keys {
        static var associatedObjects: UInt8 = .zero
    }

    private var associatedObjects: NSMutableDictionary {
        guard let associatedObjects = objc_getAssociatedObject(self, &Keys.associatedObjects) as? NSMutableDictionary else {
            let associatedObjects: NSMutableDictionary = [:]
            objc_setAssociatedObject(self, &Keys.associatedObjects, associatedObjects, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return associatedObjects
        }
        return associatedObjects
    }

    private func remove(associatedObjectFor key: AnyHashable) { associatedObjects.removeObject(forKey: key) }

    /// Retrieves an associated object for a given key.
    /// - Parameter key: The key for the object.
    /// - Returns: The object, if found.
    public func associatedObject(for key: AnyHashable) -> Any? { associatedObjects[key] }

    /// Sets an associated object for a given key.
    /// - Parameters:
    ///   - associatedObject: The object to associate. Pass `nil` to remove.
    ///   - key: The key to associate with.
    public func set(associatedObject: Any?, for key: AnyHashable) {
        associatedObject.isNotNil ? { associatedObjects[key] = associatedObject }() : remove(associatedObjectFor: key)
    }
}
