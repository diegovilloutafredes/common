//
//  ObservationTracker.swift
//

import UIKit
import Observation

// MARK: - ObservationTracker

/// Runs a content-update body under the current `ObservationMode`'s tracking policy.
enum ObservationTracker {

    /// Runs `body` now. In `.manual` mode every `@Observable` property read inside it is
    /// tracked and `onInvalidate` is scheduled on the main actor the first time one changes.
    ///
    /// `onInvalidate` must only *schedule* work (`setNeedsLayout()`), never read state:
    /// it runs after a `willSet`, so the new value is not visible yet. Re-arming happens
    /// when the caller runs `body` again on the next pass, which also coalesces bursts.
    @MainActor
    static func run(_ body: @MainActor () -> Void, onInvalidate: @escaping @MainActor () -> Void) {
        guard ObservationMode.current == .manual, #available(iOS 17.0, *) else { return body() }
        withObservationTracking {
            body()
        } onChange: {
            // Fires on the mutating thread during willSet. Hop, don't read.
            Task { @MainActor in onInvalidate() }
        }
    }
}
