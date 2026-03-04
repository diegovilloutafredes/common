//
//  String+ContainsOnlyCharactersIn.swift
//

import Foundation

extension String {
    
    /// Checks if the string contains only characters from the specified set.
    /// - Parameter matchCharacters: A string containing all allowed characters.
    /// - Returns: `true` if the string contains only allowed characters, `false` otherwise.
    public func containsOnlyCharactersIn(matchCharacters: String) -> Bool {
        let disallowedCharacterSet = CharacterSet(charactersIn: matchCharacters).inverted
        return rangeOfCharacter(from: disallowedCharacterSet) == nil
    }
}
