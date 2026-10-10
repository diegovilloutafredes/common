//
//  String+Error.swift
//

// MARK: So String may be used as an Error

/// Allows String to be used directly as an Error.
@available(*, deprecated, message: "Throw a type that conforms to Error, such as an enum.")
extension String: @retroactive Error {}
