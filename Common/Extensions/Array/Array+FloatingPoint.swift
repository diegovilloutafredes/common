//
//  Array+FloatingPoint.swift
//

import Foundation

extension Array where Element: FloatingPoint {
    public var sum: Element { reduce(0, +) }
}

extension Array where Element: FloatingPoint {
    public var average: Element { sum / Element(count) }
}

extension Array where Element: FloatingPoint {
    public var variance: Element { reduce(0, { $0 + ($1-average)*($1-average) }) }
}

extension Array where Element: FloatingPoint {
    public var standardDeviation: Element { sqrt(variance / (Element(count) - 1)) }
}
