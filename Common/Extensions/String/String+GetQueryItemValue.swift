//
//  String+GetQueryItemValue.swift
//

extension String {
    public func getQueryItemValue(_ key: String) -> String? {
        try? self.asURL().getValueFromQueryItem(key)
    }
}
