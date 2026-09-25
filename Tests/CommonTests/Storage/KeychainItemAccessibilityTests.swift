//
//  KeychainItemAccessibilityTests.swift
//

import XCTest
@testable import Common

/// Every accessibility option must resolve to a Keychain attribute (two used to trap), and reading
/// an attribute back must always give the same, canonical option.
final class KeychainItemAccessibilityTests: XCTestCase {

    func test_everyOption_resolvesToItsKeychainAttribute() {
        let expected: [(KeychainItemAccessibility, CFString)] = [
            (.afterFirstUnlock, kSecAttrAccessibleAfterFirstUnlock),
            (.afterFirstUnlockThisDeviceOnly, kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly),
            (.always, kSecAttrAccessibleAfterFirstUnlock),
            (.alwaysThisDeviceOnly, kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly),
            (.whenPasscodeSetThisDeviceOnly, kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly),
            (.whenUnlocked, kSecAttrAccessibleWhenUnlocked),
            (.whenUnlockedThisDeviceOnly, kSecAttrAccessibleWhenUnlockedThisDeviceOnly)
        ]
        for (option, attribute) in expected {
            XCTAssertEqual(option.keychainAttrValue, attribute, "\(option)")
        }
    }

    func test_sharedAttributes_mapBackToTheCanonicalOption() {
        XCTAssertEqual(KeychainItemAccessibility.accessibilityForAttributeValue(kSecAttrAccessibleAfterFirstUnlock),
                       .afterFirstUnlock)
        XCTAssertEqual(KeychainItemAccessibility.accessibilityForAttributeValue(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly),
                       .afterFirstUnlockThisDeviceOnly)
    }
}
