//
//  String+RemoveStressedVowels.swift
//

extension String {
    public func removeStressedVowels() -> String {
        replacingOccurrences(of: "á", with: "a")
        .replacingOccurrences(of: "é", with: "e")
        .replacingOccurrences(of: "í", with: "i")
        .replacingOccurrences(of: "ó", with: "o")
        .replacingOccurrences(of: "ú", with: "u")
    }
}
