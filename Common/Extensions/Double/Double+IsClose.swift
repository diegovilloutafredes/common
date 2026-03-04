//
//  Double+IsClose.swift
//

extension Double {
    
    /// Checks if the double is close to another double within a specified tolerance.
    /// - Parameters:
    ///   - other: The other double value.
    ///   - tolerance: The tolerance for equality. Defaults to `1e-9`.
    /// - Returns: `true` if the values are within the tolerance, `false` otherwise.
    public func isClose(to other: Double, tolerance: Double = 1e-9) -> Bool {
        abs(self - other) < tolerance
    }
}
