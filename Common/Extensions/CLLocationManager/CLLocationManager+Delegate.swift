//
//  CLLocationManager+Delegate.swift
//

import CoreLocation

extension CLLocationManager {
    
    /// Sets the delegate and returns self (chainable).
    /// - Parameter delegate: The delegate to set.
    @discardableResult public func delegate(_ delegate: CLLocationManagerDelegate) -> Self {
        with { $0.delegate = delegate }
    }
}
