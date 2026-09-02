//
//  ObservedCounter.swift
//

import Observation

/// Minimal `@Observable` model for the observation tests.
@available(iOS 17.0, *)
@Observable
final class ObservedCounter {
    var value: Int = .zero
}
