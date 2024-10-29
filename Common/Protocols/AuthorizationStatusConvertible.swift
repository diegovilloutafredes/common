//
//  AuthorizationStatusConvertible.swift
//

import AVFoundation
import CoreLocation
import UIKit

// MARK: - AuthorizationStatus
public enum AuthorizationStatus {
    case authorized
    case denied
    case notDetermined
}

// MARK: - AuthorizationStatusConvertible
public protocol AuthorizationStatusConvertible {
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
