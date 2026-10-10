//
//  ArrayStatisticsTests.swift
//

import XCTest
import Common

/// Sum, average, variance and standard deviation of a floating-point array.
final class ArrayStatisticsTests: XCTestCase {

    /// Mean 5, squared deviations 9, 1, 1, 1, 0, 0, 4 and 16: they add up to 32.
    private let sample: [Double] = [2, 4, 4, 4, 5, 5, 7, 9]

    // MARK: - Sum and average

    func test_sumAndAverage_ofFourElements() {
        let values: [Double] = [1, 2, 3, 4]

        XCTAssertEqual(values.sum, 10)
        XCTAssertEqual(values.average, 2.5)
    }

    func test_emptyArray_sumsToZero_andHasNoAverage() {
        let values: [Double] = []

        XCTAssertEqual(values.sum, 0)
        XCTAssertTrue(values.average.isNaN)
    }

    // MARK: - Variance

    func test_variance_isTheSampleVariance() {
        XCTAssertEqual(sample.variance, 32 / 7)
    }

    func test_variance_ofOneElement_isNaN() {
        XCTAssertTrue([3.0].variance.isNaN)
    }

    func test_variance_ofAnEmptyArray_equalsZero() {
        XCTAssertEqual([Double]().variance, 0)
    }

    // MARK: - Standard deviation

    func test_standardDeviation_isTheSquareRootOfTheSampleVariance() {
        XCTAssertEqual(sample.standardDeviation, (32.0 / 7).squareRoot())
    }

    func test_standardDeviation_ofFiveConsecutiveNumbers() {
        XCTAssertEqual([1.0, 2, 3, 4, 5].standardDeviation, (2.5).squareRoot())
    }

    func test_standardDeviation_ofOneElement_isNaN() {
        XCTAssertTrue([3.0].standardDeviation.isNaN)
    }

    func test_standardDeviation_ofAnEmptyArray_equalsZero() {
        XCTAssertEqual([Double]().standardDeviation, 0)
    }
}
