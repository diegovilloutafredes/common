//
//  StorageError.swift
//

import Foundation

// MARK: - StorageError

public enum StorageError: Error, Sendable {
    case encodingFailed(Error)
    case decodingFailed(Error)
    case keychainError(OSStatus)
    case fileIOError(Error)
    case notFound

    public var localizedDescription: String {
        switch self {
        case .encodingFailed(let error):
            return "Encoding failed: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "Decoding failed: \(error.localizedDescription)"
        case .keychainError(let status):
            switch status {
            case errSecItemNotFound:         return "Keychain item not found."
            case errSecAuthFailed:           return "Keychain authentication failed."
            case errSecInteractionNotAllowed: return "Keychain interaction not allowed (device locked)."
            default:                         return "Keychain error (OSStatus \(status))."
            }
        case .fileIOError(let error):
            return "File I/O error: \(error.localizedDescription)"
        case .notFound:
            return "Item not found."
        }
    }
}
