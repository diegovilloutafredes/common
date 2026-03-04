//
//  RawValueKeyable.swift
//

// MARK: - RawValueKeyable
// MARK: - RawValueKeyable
/// A protocol for types that use a raw representable key for storage.
public protocol RawValueKeyable {
    
    /// The type of the keys, which must be `RawRepresentable`.
    associatedtype Keys: RawRepresentable
}
