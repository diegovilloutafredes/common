//
//  Logger.swift
//

import Foundation

// MARK: - Logger
// MARK: - Logger
/// A utility for logging messages and network requests to the console.
public enum Logger {
    
    /// Logs a generic item to the console.
    /// - Parameters:
    ///   - caller: The calling function name.
    ///   - item: The item to log.
    public static func log(caller: String = #function, _ item: Any) { log(caller: caller, ["item": item]) }

    /// Logs a network request and its response.
    /// - Parameters:
    ///   - caller: The calling function name.
    ///   - request: The URL request.
    ///   - data: The response data.
    ///   - response: The URL response.
    public static func log(caller: String = #function, _ request: URLRequest, data: Data? = nil, response: URLResponse?) {
        let httpResponse = response as? HTTPURLResponse
        let statusCode = httpResponse?.statusCode ?? -1
        let requestHeaders = request.allHTTPHeaderFields ?? [:]
        let responseHeaders = httpResponse?.allHeaderFields as? [String: String] ?? [:]
        let url = request.url
        let httpMethod = request.httpMethod
        let httpBody = request.httpBody
        let body = httpBody?.asString() ?? .empty
        
        log(
            caller: caller,
            [
                "STATUS CODE": statusCode.asString,
                "URL": url?.absoluteString ?? .empty,
                "REQUEST HEADERS": requestHeaders.asString() ?? .empty,
                "RESPONSE HEADERS": responseHeaders.asString() ?? .empty,
                "METHOD": httpMethod ?? .empty,
                "DATA": data?.asString() ?? .empty,
                "BODY": body
            ].filter { $0.value.isNotEmpty }
        )
    }

    /// Logs a dictionary of items to the console with a structured format.
    /// - Parameters:
    ///   - caller: The calling function name.
    ///   - items: The items to log.
    public static func log(caller: String = #function, _ items: [String: Any]) {
        guard shouldLog else { return }

        let topText = "🎯 \(bundleIdentifier)"
        let bottomText = currentTime
        let defaultLength = [topText.count, bottomText.count].max() ?? .zero
        let difference = abs(topText.count - bottomText.count)/2 + 1

        var topDifference: Int { topText.count > bottomText.count ? difference : .zero }
        var bottomDifference: Int { bottomText.count > topText.count ? difference : .zero }

        let topCount = defaultLength - topDifference
        let bottomCount = defaultLength - bottomDifference

        var topUnderscores: String { underscores(topCount) }
        var bottomUnderscores: String { underscores(bottomCount) }

        let topContent = [topUnderscores, topText, topUnderscores].joined(separator: " ")
        let bottomContent = [bottomUnderscores, bottomText, bottomUnderscores].joined(separator: " ")

        print("\n\(topContent)")
        print(item(title: "Caller", value: caller))
        items.sorted { $0.key < $1.key }.forEach { print(item(title: $0.key, value: $0.value)) }
        print("\(bottomContent)\n")
    }
}

// MARK: - Loggable
extension Logger: Loggable {}


// MARK: - Convenience
extension Logger {
    private static var bundleIdentifier: String { Bundle.main.bundleIdentifier?.uppercased() ?? "\(self)" }
    private static var currentTime: String { Date().toString(with: .DateFormats.ddMMyyyyHHmm) }
    private static func item(title: String, value: Any) -> String { "| 🔸 \(title): \(value)" }
    private static func underscores(_ count: Int) -> String { Array(repeating: "_", count: count).joined() }
}
