//
//  String+QueryItems.swift
//

extension String {
    public var queryItems: [URLQueryItem]? { try? self.asURL().queryItems }
}
