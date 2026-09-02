//
//  ObservationMode.swift
//

import UIKit

// MARK: - ObservationMode

/// How Common re-runs `updateContent()` / `onUpdateProperties()` when `@Observable`
/// state read inside those hooks changes.
///
/// The mode is decided per process from the OS version. Consumers do not choose it;
/// it is exposed so screens can display or log which mechanism is active.
public enum ObservationMode: Sendable {

    /// iOS 26+: UIKit's `updateProperties()` tracks the reads natively.
    case native

    /// iOS 17–18: Common wraps the hook in `withObservationTracking` and re-arms it on
    /// the next layout pass. Works with or without the app's `UIObservationTrackingEnabled` key.
    case manual

    /// iOS 16: the hook runs on every layout pass with no tracking.
    case unavailable

    /// The mode in effect for this process.
    @MainActor public static var current: ObservationMode {
        if let override { return override }
        if #available(iOS 26.0, *) { return .native }
        if #available(iOS 17.0, *) { return .manual }
        return .unavailable
    }

    /// Test seam: forces a mode regardless of OS. Internal on purpose — tests reset it
    /// to `nil` in `tearDown`.
    @MainActor static var override: ObservationMode?
}
