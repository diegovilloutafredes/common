//
//  Bundle+GetValueFromPlist.swift
//

extension Bundle {
    public func getValueFromPlist<T>(for key: String, on resource: String) -> T? {
        guard
            let path = path(forResource: resource, ofType: "plist"),
            let plist = NSDictionary(contentsOfFile: path)
        else { return nil }
        return plist.object(forKey: key) as? T
    }
}
