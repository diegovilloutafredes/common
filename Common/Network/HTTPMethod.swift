//
//  HTTPMethod.swift
//

/// Represents an HTTP method.
public struct HTTPMethod: RawRepresentable, Equatable, Hashable {
    
    /// The `CONNECT` method.
    public static let connect = HTTPMethod(rawValue: "CONNECT")
    
    /// The `DELETE` method.
    public static let delete = HTTPMethod(rawValue: "DELETE")
    
    /// The `GET` method.
    public static let get = HTTPMethod(rawValue: "GET")
    
    /// The `HEAD` method.
    public static let head = HTTPMethod(rawValue: "HEAD")
    
    /// The `OPTIONS` method.
    public static let options = HTTPMethod(rawValue: "OPTIONS")
    
    /// The `PATCH` method.
    public static let patch = HTTPMethod(rawValue: "PATCH")
    
    /// The `POST` method.
    public static let post = HTTPMethod(rawValue: "POST")
    
    /// The `PUT` method.
    public static let put = HTTPMethod(rawValue: "PUT")
    
    /// The `QUERY` method.
    public static let query = HTTPMethod(rawValue: "QUERY")
    
    /// The `TRACE` method.
    public static let trace = HTTPMethod(rawValue: "TRACE")

    /// The raw string value of the HTTP method.
    public let rawValue: String

    /// Initializes an `HTTPMethod` with a raw string value.
    /// - Parameter rawValue: The string representation of the HTTP method.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}
