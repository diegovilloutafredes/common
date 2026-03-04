//
//  Calendar+NumberOfDaysBetweenDates.swift
//

import Foundation

extension Calendar {
    
    /// Calculates the number of days between two dates, ignoring time components (start of day).
    /// - Parameters:
    ///   - from: The start date.
    ///   - to: The end date.
    /// - Returns: The number of days between the two dates.
    public func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
        let fromDate = startOfDay(for: from)
        let toDate = startOfDay(for: to)
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate)
        return numberOfDays.day ?? .zero
    }

    /// Calculates the number of days between two dates, considering the time components.
    /// - Parameters:
    ///   - from: The start date.
    ///   - to: The end date.
    /// - Returns: The number of days between the two dates.
    public func numberOfDaysConsideringHoursBetween(_ from: Date, and to: Date) -> Int {
        let numberOfDays = dateComponents([.day], from: from, to: to)
        return numberOfDays.day ?? .zero
    }
}
