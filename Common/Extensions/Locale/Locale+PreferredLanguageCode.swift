//
//  Locale+PreferredLanguageCode.swift
//

import Foundation

extension Locale {
    static var preferredLanguageCode: String {
        guard
            let preferredLanguage = preferredLanguages.first,
            let languageCode = Locale(identifier: preferredLanguage).languageCode
        else { return "es" }
        return languageCode
    }
}
