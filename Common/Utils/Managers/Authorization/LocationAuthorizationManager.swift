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

    private let makeLocationManager: () -> CLLocationManager
    private lazy var locationManager = makeLocationManager()
        .delegate(self)

    /// Handlers of requests still waiting for the user's decision. Only touched on the main thread.
    private var pendingHandlers: [Handler<AuthorizationStatus>] = []

    /// Creates a manager whose Core Location manager is created on first use.
    public override init() {
        makeLocationManager = { CLLocationManager() }
        super.init()
    }

    /// Uses the given Core Location manager. Test seam.
    init(locationManager: CLLocationManager) {
        makeLocationManager = { locationManager }
        super.init()
    }

    /// The current location authorization status.
    public var currentStatus: AuthorizationStatus { locationManager.authorizationStatus.asAuthorizationStatus }

    /// Requests location authorization.
    ///
    /// The handler is called exactly once, on the main thread: right away when the user has already decided, otherwise
    /// with the user's decision after the prompt. Later changes are not reported to it; use a `CLLocationManager`
    /// delegate for continuous updates. The request reaches Core Location either way, so a request for Always made
    /// with When In Use access can still show the upgrade prompt (both report `.authorized`). Runs on the main thread.
    /// - Parameters:
    ///   - authorizationType: The type of authorization to request (always or when in use).
    ///   - handler: Completion handler with the authorization status.
    public func request(_ authorizationType: AuthorizationType, handler: Handler<AuthorizationStatus>? = nil) {
        onMainThread { [self] in
            if let handler {
                let status = currentStatus
                if status == .notDetermined { pendingHandlers.append(handler) } else { handler(status) }
            }
            switch authorizationType {
            case .always: locationManager.requestAlwaysAuthorization()
            case .whenInUse: locationManager.requestWhenInUseAuthorization()
            }
        }
    }

    /// Runs `work` on the main thread: right away when already there, otherwise as a main-actor task.
    private func onMainThread(_ work: @escaping () -> Void) {
        guard Thread.isMainThread else { Task { @MainActor in work() }; return }
        work()
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationAuthorizationManager: CLLocationManagerDelegate {
    /// Answers the pending requests with the first determined status. Core Location also reports when the manager is
    /// created, before the user has decided; a not-determined report answers nothing.
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus.asAuthorizationStatus
        guard status != .notDetermined else { return }
        onMainThread { [self] in
            let handlers = pendingHandlers
            pendingHandlers.removeAll()
            handlers.forEach { $0(status) }
        }
    }
}
