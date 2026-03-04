//
//  String+GetFromPlist.swift
//

import Foundation

extension String {
    
    /// Retrieves a string value from a Plist file.
    /// - Parameters:
    ///   - key: The key to retrieve.
    ///   - resource: The name of the plist resource. Defaults to "Info".
    ///   - bundle: The bundle to search in. Defaults to `.main`.
    /// - Returns: The string value, or `nil` if not found.
    public static func getFromPlist(for key: String, on resource: String = "Info", using bundle: Bundle = .main) -> String? {
        bundle.getValueFromPlist(for: key, on: resource)
    }
}
