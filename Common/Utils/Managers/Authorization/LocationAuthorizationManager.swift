//
//  LocationAuthorizationManager.swift
//

import CoreLocation

public final class LocationAuthorizationManager: NSObject {
    public enum AuthorizationType {
        case always
        case whenInUse
    }

    private lazy var locationManager = CLLocationManager()
        .delegate(self)

    private var requestHandler: Handler<AuthorizationStatus>?

    public func request(_ authorizationType: AuthorizationType, handler: Handler<AuthorizationStatus>? = nil) {
        requestHandler = handler
        switch authorizationType {
        case .always:
            locationManager.requestAlwaysAuthorization()
        case .whenInUse:
            locationManager.requestWhenInUseAuthorization()
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationAuthorizationManager: CLLocationManagerDelegate {
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        requestHandler?(manager.authorizationStatus.asAuthorizationStatus)
    }
}

extension CLLocationManager {
    @discardableResult public func delegate(_ delegate: CLLocationManagerDelegate) -> Self {
        with { $0.delegate = delegate }
    }
}
