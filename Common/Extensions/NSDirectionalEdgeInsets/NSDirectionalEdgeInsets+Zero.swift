//
//  NSDirectionalEdgeInsets+Zero.swift
//

import UIKit

extension NSDirectionalEdgeInsets {
    
    /// Returns a `NSDirectionalEdgeInsets` with all edges set to zero.
    public static var zero: NSDirectionalEdgeInsets { .init(top: .zero, leading: .zero, bottom: .zero, trailing: .zero) }
}
