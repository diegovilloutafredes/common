//
//  IndexPath+Zero.swift
//

extension IndexPath {
    
    /// Returns an index path with item and section set to zero.
    public static var zero: IndexPath { .init(item: .zero, section: .zero) }
}
