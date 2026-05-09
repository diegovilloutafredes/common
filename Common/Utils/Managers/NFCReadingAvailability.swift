//
//  NFCReadingAvailability.swift
//

import CoreNFC

/// A utility to check if NFC reading is available on the device.
public enum NFCReadingAvailability {
    
    /// Returns `true` if NFC reading is available.
    /// Requires the `com.apple.developer.nfc.readersession.formats` entitlement — returns `false` without it.
    public static var isReadingAvailable: Bool { NFCReaderSession.readingAvailable }
}
