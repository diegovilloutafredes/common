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

    public func set(associatedObject: Any?, for key: AnyHashable) {
        associatedObject.isNotNil ? { associatedObjects[key] = associatedObject }() : remove(associatedObjectFor: key)
    }

    public func associatedObject(for key: AnyHashable) -> Any? { associatedObjects[key] }
}
