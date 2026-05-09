//
//  Debouncer.swift
//

import Foundation

// MARK: - Debouncer
/// A utility for debouncing function calls, ensuring they are executed only after a specified delay.
@MainActor
public final class Debouncer {
    public static let shared = Debouncer()
    private var timers: [String: Timer] = [:]

    private init() {}

    /// Debounces a function call.
    /// - Parameters:
    ///   - from: The identifier of the caller (default: function name).
    ///   - id: An optional unique identifier to distinguish multiple calls from the same function.
    ///   - seconds: The debounce delay in seconds.
    ///   - function: The function to execute after the delay.
    public static func debounce(from: String = #function, id: String = .empty, seconds: TimeInterval, function: @escaping () -> Void) {
        shared._debounce(key: from + id, seconds: seconds, function: function)
    }

    private func _debounce(key: String, seconds: TimeInterval, function: @escaping () -> Void) {
        timers[key]?.invalidate()
        let timer = Timer(timeInterval: seconds, repeats: false) { [weak self, key] _ in
            function()
            Task { @MainActor [weak self] in self?.timers[key] = nil }
        }
        RunLoop.main.add(timer, forMode: .common)
        timers[key] = timer
    }
}
