//
//  String+QueryItems.swift
//

extension String {
    
    /// Parses the string as a URL and retrieves its query items.
    public var queryItems: [URLQueryItem]? { try? self.asURL().queryItems }
}
