//
//  Float+IsClose.swift
//

extension Float {
    
    /// Checks if the float is close to another float within a specified tolerance.
    /// - Parameters:
    ///   - other: The other float value.
    ///   - tolerance: The tolerance for equality. Defaults to `1e-7`.
    /// - Returns: `true` if the values are within the tolerance, `false` otherwise.
    public func isClose(to other: Float, tolerance: Float = 1e-7) -> Bool {
        abs(self - other) < tolerance
    }
}
