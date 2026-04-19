//
//  Locale+PreferredLanguageCode.swift
//

import Foundation

extension Locale {
    
    /// Returns the preferred language code of the device.
    /// Defaults to "es" if it cannot be determined.
    static var preferredLanguageCode: String {
        guard
            let preferredLanguage = preferredLanguages.first,
            let languageCode = Locale(identifier: preferredLanguage).language.languageCode?.identifier
        else { return "es" }
        return languageCode
    }
}
