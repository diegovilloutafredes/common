//
//  Array+FloatingPoint.swift
//

import Foundation

extension Array where Element: FloatingPoint {
    /// Calculates the sum of all elements in the array.
    public var sum: Element { reduce(0, +) }
}

extension Array where Element: FloatingPoint {
    /// Calculates the average (mean) of the elements in the array.
    public var average: Element { sum / Element(count) }
}

extension Array where Element: FloatingPoint {
    /// The sample variance: the sum of the squared deviations from `average`, divided by `count - 1`.
    ///
    /// NaN for a single element, and a value equal to zero for an empty array.
    public var variance: Element {
        let avg = average
        return reduce(0) { $0 + ($1 - avg) * ($1 - avg) } / (Element(count) - 1)
    }
}

extension Array where Element: FloatingPoint {
    /// The sample standard deviation: the square root of `variance`.
    ///
    /// NaN for a single element, and a value equal to zero for an empty array.
    public var standardDeviation: Element { sqrt(variance) }
}
