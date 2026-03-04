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
    /// Calculates the variance of the elements in the array.
    public var variance: Element { reduce(0, { $0 + ($1-average)*($1-average) }) }
}

extension Array where Element: FloatingPoint {
    /// Calculates the standard deviation of the elements in the array.
    public var standardDeviation: Element { sqrt(variance / (Element(count) - 1)) }
}
