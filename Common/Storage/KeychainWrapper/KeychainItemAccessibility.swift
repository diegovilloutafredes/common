import Foundation

public protocol KeychainAttrRepresentable {
    var keychainAttrValue: CFString { get }
}

// MARK: - KeychainItemAccessibility
/// Defines the accessibility options for keychain items.
public enum KeychainItemAccessibility {
    
    /// The data in the keychain item can only be accessed after the first unlock.
    case afterFirstUnlock
    
    /// The data in the keychain item can only be accessed after the first unlock, and only on this device.
    case afterFirstUnlockThisDeviceOnly
    
    /// Stored as `afterFirstUnlock`: the Keychain's always-accessible class is deprecated, and
    /// after-first-unlock is its designated replacement. The item is readable once the device has
    /// been unlocked after a restart, including while it is locked again.
    case always

    /// The data in the keychain can only be accessed when the device is unlocked. Only available if a passcode is set on the device.
    ///
    /// This is recommended for items that only need to be accessible while the application is in the foreground.
    /// Items with this attribute never migrate to a new device. After a backup is restored to a new device, these items are missing.
    /// No items can be stored in this class on devices without a passcode. Disabling the device passcode causes all items in this class to be deleted.
    @available(iOS 8, *)
    case whenPasscodeSetThisDeviceOnly

    /// Stored as `afterFirstUnlockThisDeviceOnly`: the Keychain's always-accessible class is deprecated,
    /// and after-first-unlock is its designated replacement. The item is readable once the device has
    /// been unlocked after a restart, and does not migrate to a new device.
    case alwaysThisDeviceOnly
    
    /// The data in the keychain item can be accessed only while the device is unlocked by the user.
    ///
    /// This is recommended for items that need to be accessible only while the application is in the foreground. Items with this attribute migrate to a new device when using encrypted backups.
    ///
    /// This is the default value for keychain items added without explicitly setting an accessibility constant.
    case whenUnlocked
    
    /// The data in the keychain item can be accessed only while the device is unlocked by the user.
    ///
    /// This is recommended for items that need to be accessible only while the application is in the foreground. Items with this attribute do not migrate to a new device.
    /// Thus, after restoring from a backup of a different device, these items will not be present.
    case whenUnlockedThisDeviceOnly

    /// Maps an attribute back to its option. Only the canonical options are candidates: `.always` and
    /// `.alwaysThisDeviceOnly` share their attributes, so the answer is the same on every call.
    static func accessibilityForAttributeValue(_ keychainAttrValue: CFString) -> KeychainItemAccessibility? {
        let canonical: [KeychainItemAccessibility] = [
            .afterFirstUnlock, .afterFirstUnlockThisDeviceOnly, .whenPasscodeSetThisDeviceOnly, .whenUnlocked, .whenUnlockedThisDeviceOnly
        ]
        return canonical.first { $0.keychainAttrValue == keychainAttrValue }
    }
}

extension KeychainItemAccessibility: KeychainAttrRepresentable {
    public var keychainAttrValue: CFString {
        switch self {
        case .afterFirstUnlock, .always: kSecAttrAccessibleAfterFirstUnlock
        case .afterFirstUnlockThisDeviceOnly, .alwaysThisDeviceOnly: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        case .whenPasscodeSetThisDeviceOnly: kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
        case .whenUnlocked: kSecAttrAccessibleWhenUnlocked
        case .whenUnlockedThisDeviceOnly: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        }
    }
}
