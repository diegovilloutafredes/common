//
//  CLAuthorizationStatus+AuthorizationStatusConvertible.swift
//

import CoreLocation

// MARK: - AuthorizationStatusConvertible
/// Conformance to `AuthorizationStatusConvertible` to allow converting between different authorization status types.
extension CLAuthorizationStatus: AuthorizationStatusConvertible {}
