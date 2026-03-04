//
//  Debouncer.swift
//

import Foundation

// MARK: - Debouncer
// MARK: - Debouncer
/// A utility for debouncing function calls, ensuring they are executed only after a specified delay.
public struct Debouncer {
    private static var shared = Debouncer()
    private var timers: [String: Timer] = [:]

    private init() {}

    /// Debounces a function call.
    /// - Parameters:
    ///   - from: The identifier of the caller (default: function name).
    ///   - id: An optional unique identifier to distinguish multiple calls from the same function.
    ///   - seconds: The debounce delay in seconds.
    ///   - function: The function to execute after the delay.
    public static func debounce(from: String = #function, id: String = .empty, seconds: TimeInterval, function: @escaping () -> Void) {
        let key = from + id
        shared.timers[key]?.invalidate()
        shared.timers[key] = .scheduledTimer(
            withTimeInterval: seconds,
            repeats: false,
            block: { _ in function() }
        )
    }
}
