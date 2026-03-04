//
//  Date+-.swift
//

import Foundation

extension Date {
    
    /// Calculates the time interval between two dates.
    /// - Parameters:
    ///   - lhs: The first date.
    ///   - rhs: The second date.
    /// - Returns: The time interval between the two dates.
    public static func - (lhs: Date, rhs: Date) -> TimeInterval { lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate }
}
