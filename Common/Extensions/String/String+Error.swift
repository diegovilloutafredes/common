//
//  String+Error.swift
//

// MARK: So String may be used as an Error
// MARK: So String may be used as an Error

/// Allows String to be used directly as an Error.
extension String: @retroactive Error {}
