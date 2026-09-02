//
//  ObservationTracker.swift
//

import UIKit
import Observation

// MARK: - ObservationTracker

/// Runs a content-update body under the current `ObservationMode`'s tracking policy.
enum ObservationTracker {

    /// Runs `body` now. In `.manual` mode every `@Observable` property read inside it is
    /// tracked and `onInvalidate` runs on the main actor the first time one changes:
    /// synchronously when the mutation happens on the main thread (matching UIKit's native
    /// timing), otherwise after one hop.
    ///
    /// `onInvalidate` must only *schedule* work (`setNeedsLayout()`), never read state:
    /// it runs during a `willSet`, so the new value is not visible yet. Re-arming happens
    /// when the caller runs `body` again on the next pass, which also coalesces bursts.
    @MainActor
    static func run(_ body: @MainActor () -> Void, onInvalidate: @escaping @MainActor () -> Void) {
        guard ObservationMode.current == .manual, #available(iOS 17.0, *) else { return body() }
        withObservationTracking {
            body()
        } onChange: {
            // Fires on the mutating thread during willSet. Schedule, don't read.
            if Thread.isMainThread {
                MainActor.assumeIsolated { onInvalidate() }
            } else {
                Task { @MainActor in onInvalidate() }
            }
        }
    }
}
