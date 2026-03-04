//
//  String+GetQueryItemValue.swift
//

extension String {
    
    /// Extracts a query item value from the string assuming it is a URL.
    /// - Parameter key: The query parameter key.
    /// - Returns: The value of the query parameter, or `nil` if not found.
    public func getQueryItemValue(_ key: String) -> String? {
        try? self.asURL().getValueFromQueryItem(key)
    }
}
