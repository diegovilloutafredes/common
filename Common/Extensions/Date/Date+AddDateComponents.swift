//
//  Date+AddDateComponents.swift
//

import Foundation

extension Date {
    public func add(seconds: Int = .zero, minutes: Int = .zero, hours: Int = .zero, days: Int = .zero) -> Date {
        let dateComponents = DateComponents()
            .with {
                $0.second = seconds
                $0.minute = minutes
                $0.hour = hours
                $0.day = days
            }
        return Calendar.current.date(byAdding: dateComponents, to: self) ?? self
    }
}
