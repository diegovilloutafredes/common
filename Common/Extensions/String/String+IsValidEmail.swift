//
//  String+IsValidEmail.swift
//

import Foundation

// MARK: - Is Valid Email
extension String {
    public func isValidEmail() -> Bool {
        guard !lowercased().hasPrefix("mailto:") else { return false }

        guard
            let emailDetector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        else { return false }

        let matches = emailDetector.matches(
            in: self,
            options: NSRegularExpression.MatchingOptions.anchored,
            range: NSRange(location: 0, length: count)
        )

        guard matches.count == 1 else { return false }

        return matches[0].url?.scheme == "mailto"
    }
}
