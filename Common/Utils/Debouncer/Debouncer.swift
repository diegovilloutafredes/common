//
//  Debouncer.swift
//

import Foundation

// MARK: - Debouncer
public struct Debouncer {
    private static var shared = Debouncer()
    private var timers: [String: Timer] = [:]
    private let queue: DispatchQueue = .main

    private init() {}

    public static func debounce(from: String = #function, id: String = .empty, seconds: TimeInterval, function: @escaping () -> Void) {
        let key = from + id
        shared.timers[key]?.invalidate()
        shared.timers[key] = Timer.scheduledTimer(
            withTimeInterval: seconds,
            repeats: false,
            block: { _ in function() }
        )
    }
}
