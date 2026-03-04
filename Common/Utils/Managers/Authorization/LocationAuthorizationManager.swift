//
//  LocationAuthorizationManager.swift
//

import CoreLocation

// MARK: - LocationAuthorizationManager
/// Manages location services authorization.
public final class LocationAuthorizationManager: NSObject {
    
    /// Defines the type of location authorization requested.
    public enum AuthorizationType {
        /// App requests location access always.
        case always
        /// App requests location access only when in use.
        case whenInUse
    }

    private lazy var locationManager = CLLocationManager()
        .delegate(self)

    private var requestHandler: Handler<AuthorizationStatus>?

    /// Requests location authorization.
    /// - Parameters:
    ///   - authorizationType: The type of authorization to request (always or when in use).
    ///   - handler: Completion handler with the new authorization status.
    public func request(_ authorizationType: AuthorizationType, handler: Handler<AuthorizationStatus>? = nil) {
        requestHandler = handler
        switch authorizationType {
        case .always: locationManager.requestAlwaysAuthorization()
        case .whenInUse: locationManager.requestWhenInUseAuthorization()
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationAuthorizationManager: CLLocationManagerDelegate {
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        requestHandler?(manager.authorizationStatus.asAuthorizationStatus)
    }
}
