//
//  String+GetQueryParameter.swift
//

extension String {
    public func getQueryParameter(_ key: String) -> String? {
        try? self.asURL().getValueFromQueryItem(key)
    }
}
