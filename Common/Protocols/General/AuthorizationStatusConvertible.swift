//
//  AuthorizationStatusConvertible.swift
//

import AVFoundation
import CoreLocation
import UIKit

// MARK: - AuthorizationStatus
// MARK: - AuthorizationStatus
/// Represents the authorization status for various system services.
public enum AuthorizationStatus {
    /// The service is authorized.
    case authorized
    /// The service is denied or restricted.
    case denied
    /// The authorization status has not been determined yet.
    case notDetermined
}

// MARK: - AuthorizationStatusConvertible
/// A protocol for types that can be converted to an `AuthorizationStatus`.
public protocol AuthorizationStatusConvertible {
    
    /// The authorization status value.
    var asAuthorizationStatus: AuthorizationStatus { get }
}

// MARK: - where Self == AVAuthorizationStatus
extension AuthorizationStatusConvertible where Self == AVAuthorizationStatus {
    public var asAuthorizationStatus: AuthorizationStatus {
        switch self {
        case .authorized: .authorized
        case .denied, .restricted: .denied
        default: .notDetermined
        }
    }
}

// MARK: - where Self == CLAuthorizationStatus
extension AuthorizationStatusConvertible where Self == CLAuthorizationStatus {
    public var asAuthorizationStatus: AuthorizationStatus {
        switch self {
        case .authorized, .authorizedAlways, .authorizedWhenInUse: .authorized
        case .denied, .restricted: .denied
        case .notDetermined: .notDetermined
        @unknown default: .notDetermined
        }
    }
}

// MARK: - where Self == UNAuthorizationStatus
extension AuthorizationStatusConvertible where Self == UNAuthorizationStatus {
    public var asAuthorizationStatus: AuthorizationStatus {
        switch self {
        case .authorized, .ephemeral, .provisional: .authorized
        case .denied: .denied
        case .notDetermined: .notDetermined
        @unknown default: .notDetermined
        }
    }
}
