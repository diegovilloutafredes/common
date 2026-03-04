//
//  CGFloat+IsClose.swift
//

extension CGFloat {
    
    /// Checks if the value is close to another value within a specified tolerance.
    /// - Parameters:
    ///   - other: The value to compare with.
    ///   - tolerance: The maximum difference allowed. Defaults to 1e-9.
    /// - Returns: `true` if the values are within the tolerance.
    public func isClose(to other: CGFloat, tolerance: CGFloat = 1e-9) -> Bool {
        abs(self - other) < tolerance
    }
}
