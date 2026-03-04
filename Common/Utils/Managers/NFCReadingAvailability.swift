//
//  NFCReadingAvailability.swift
//

import CoreNFC

/// A utility to check if NFC reading is available on the device.
public enum NFCReadingAvailability {
    
    /// Returns `true` if NFC reading is available.
    public static var isReadingAvailable: Bool { NFCReaderSession.readingAvailable }
}
