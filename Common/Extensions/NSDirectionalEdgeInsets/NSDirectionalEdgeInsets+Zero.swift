//
//  NSDirectionalEdgeInsets+Zero.swift
//

import UIKit

extension NSDirectionalEdgeInsets {
    
    /// Returns a `NSDirectionalEdgeInsets` with all edges set to zero.
    // Disfavored: UIKit declares it with the same type and value, and a file importing both modules was ambiguous.
    @_disfavoredOverload
    public static var zero: NSDirectionalEdgeInsets { .init(top: .zero, leading: .zero, bottom: .zero, trailing: .zero) }
}
