//
//  Int+AsHoursMinutesSecondsString.swift
//

import Foundation

extension Int {
    
    /// Formats the integer (seconds) into a "HH:mm:ss" positional string.
    /// - Returns: The formatted time string or empty if formatting fails.
    public func asHoursMinutesSecondsString() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        guard let formattedString = formatter.string(from: .init(self)) else { return .empty }
        return formattedString
    }
}
