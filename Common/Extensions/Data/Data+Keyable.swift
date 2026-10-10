//
//  Data+Keyable.swift
//

import Foundation

/// Adds `Keyable` conformance to `Data`.
@available(*, deprecated, message: "Every Data of the same length gets the same key. Use a key derived from the content, such as its base64 encoding.")
extension Data: Keyable {}
