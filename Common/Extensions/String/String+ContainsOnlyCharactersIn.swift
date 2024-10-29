//
//  String+ContainsOnlyCharactersIn.swift
//

import Foundation

extension String {
    public func containsOnlyCharactersIn(matchCharacters: String) -> Bool {
        let disallowedCharacterSet = CharacterSet(charactersIn: matchCharacters).inverted
        return rangeOfCharacter(from: disallowedCharacterSet) == nil
    }
}
