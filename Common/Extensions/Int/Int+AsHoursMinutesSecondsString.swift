//
//  Int+AsHoursMinutesSecondsString.swift
//

import Foundation

extension Int {
    public func asHoursMinutesSecondsString() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        guard let formattedString = formatter.string(from: .init(self)) else { return .empty }
        return formattedString
    }
}
