//
//  String+Random.swift
//

extension String {
    
    /// Generates a random alphanumeric string of the specified length.
    /// - Parameter length: The length of the string to generate.
    /// - Parameter chars: The chars from where the random string is generated..
    /// - Returns: A random string.
    public static func random(length: Int, chars: String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789") -> String {
        .init( (.zero..<length).compactMap { _ in chars.randomElement() } )
    }
}
