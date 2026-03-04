//
//  CGRect+IsClose.swift
//

extension CGRect {
    
    /// Checks if the rectangle is close to another rectangle within a specified tolerance using origin and size.
    /// - Parameters:
    ///   - other: The rectangle to compare with.
    ///   - tolerance: The maximum difference allowed. Defaults to 1e-9.
    /// - Returns: `true` if origin and size components are close.
    public func isClose(to other: CGRect, tolerance: CGFloat = 1e-9) -> Bool {
        origin.x.isClose(to: other.origin.x, tolerance: tolerance) &&
        origin.y.isClose(to: other.origin.y, tolerance: tolerance) &&
        size.width.isClose(to: other.size.width, tolerance: tolerance) &&
        size.height.isClose(to: other.size.height, tolerance: tolerance)
    }
}
