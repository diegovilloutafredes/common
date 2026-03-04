//
//  Bundle+GetValueFromPlist.swift
//

extension Bundle {
    
    /// Retrieves a value from a Plist file in the bundle.
    /// - Parameters:
    ///   - key: The key to retrieve.
    ///   - resource: The name of the plist resource (without extension).
    /// - Returns: The value associated with the key, or `nil` if not found or type mismatch.
    public func getValueFromPlist<T>(for key: String, on resource: String) -> T? {
        guard
            let path = path(forResource: resource, ofType: "plist"),
            let plist = NSDictionary(contentsOfFile: path)
        else { return nil }
        return plist.object(forKey: key) as? T
    }
}
