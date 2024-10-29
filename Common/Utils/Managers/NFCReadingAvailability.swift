//
//  NFCReadingAvailability.swift
//

import CoreNFC

public enum NFCReadingAvailability {
    public static var isReadingAvailable: Bool { NFCReaderSession.readingAvailable }
}
