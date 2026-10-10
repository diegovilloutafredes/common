//
//  String+RemoveStressedVowels.swift
//

extension String {
    @available(*, deprecated, message: "Use folding(options: .diacriticInsensitive, locale:), which also handles uppercase letters and turns ñ into n.")
    public func removeStressedVowels() -> String {
        replacingOccurrences(of: "á", with: "a")
        .replacingOccurrences(of: "é", with: "e")
        .replacingOccurrences(of: "í", with: "i")
        .replacingOccurrences(of: "ó", with: "o")
        .replacingOccurrences(of: "ú", with: "u")
    }
}
