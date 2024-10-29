//
//  String+GetFromPlist.swift
//

import Foundation

extension String {
    public static func getFromPlist(for key: String, on resource: String = "Info", using bundle: Bundle = .main) -> String? {
        bundle.getValueFromPlist(for: key, on: resource)
    }
}
