//
//  String+AsDecimalNumber.swift
//

import Foundation

extension String {
    
    /// Attempts to convert the string to an Int, then formats it as a decimal number string (es_CL locale).
    /// - Returns: The formatted string or `nil` if conversion fails.
    public var asDecimalNumber: String? { asInt?.asDecimalNumber }
}
