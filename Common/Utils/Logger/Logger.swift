//
//  Logger.swift
//

import Foundation

// MARK: - Logger
/// A utility for logging messages and network requests to the console.
public enum Logger {
    
    /// Logs a generic item to the console.
    /// - Parameters:
    ///   - caller: The calling function name.
    ///   - item: The item to log.
    // Disfavored so dictionary literals resolve to the KeyValuePairs overload
    // (Swift otherwise prefers converting the literal's default Dictionary type to Any).
    @_disfavoredOverload
    public static func log(caller: String = #function, _ item: Any) { log(caller: caller, orderedItems: [("item", item)]) }

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
        
        let orderedItems: [(String, String)] = [
            ("STATUS CODE", statusCode.asString),
            ("URL", url?.absoluteString ?? .empty),
            ("REQUEST HEADERS", requestHeaders.asString() ?? .empty),
            ("RESPONSE HEADERS", responseHeaders.asString() ?? .empty),
            ("METHOD", httpMethod ?? .empty),
            ("DATA", data?.asString() ?? .empty),
            ("BODY", body)
        ]

        log(
            caller: caller,
            orderedItems: orderedItems
                .filter { $0.1.isNotEmpty }
                .map { ($0.0, $0.1 as Any) }
        )
    }

    /// Logs items to the console with a structured format, in call-site order.
    /// - Parameters:
    ///   - caller: The calling function name.
    ///   - items: The items to log; printed in the order they are written.
    public static func log(caller: String = #function, _ items: KeyValuePairs<String, Any>) {
        log(caller: caller, orderedItems: items.map { ($0.key, $0.value) })
    }

    /// Logs a dictionary of items to the console with a structured format.
    /// Output order is unspecified — prefer the `KeyValuePairs` overload.
    /// - Parameters:
    ///   - caller: The calling function name.
    ///   - items: The items to log.
    @available(*, deprecated, message: "Pass a literal (KeyValuePairs) to preserve output order.")
    @_disfavoredOverload
    public static func log(caller: String = #function, _ items: [String: Any]) {
        log(caller: caller, orderedItems: items.map { ($0.key, $0.value) })
    }

    private static func log(caller: String, orderedItems: [(String, Any)]) {
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

        // Emit the whole frame in a single print so concurrent logs can't interleave lines.
        let lines = ["\n\(topContent)", item(title: "Caller", value: caller)]
            + orderedItems.map { item(title: $0.0, value: $0.1) }
            + ["\(bottomContent)\n"]
        print(lines.joined(separator: "\n"))
    }
}

// MARK: - Loggable
extension Logger: Loggable {}

// MARK: - Compile-time gate
extension Logger {
    #if DEBUG
    public static let isCompileTimeEnabled = true
    #else
    public static let isCompileTimeEnabled = false
    #endif

    /// Runtime override for the compile-time gate. When `true`, `Loggable.shouldLog`
    /// honours its stored value regardless of how the framework was built.
    ///
    /// Intended for debug builds of consumer apps that link a Release-archived
    /// `Common.xcframework` (in which `isCompileTimeEnabled` is baked as `false`).
    /// Flip this once at app startup, then control individual subsystems via
    /// their own `<Type>.shouldLog`. Prefer the fluent form:
    /// ```
    /// #if DEBUG
    /// Logger.isRuntimeForceEnabled(true)
    /// HTTPService.shouldLog(true)
    /// #endif
    /// ```
    /// Release apps should leave this off.
    public nonisolated(unsafe) static var isRuntimeForceEnabled: Bool = false

    /// Fluent setter for `isRuntimeForceEnabled`. Returns the type for chaining.
    @discardableResult
    public static func isRuntimeForceEnabled(_ value: Bool) -> Self.Type {
        isRuntimeForceEnabled = value
        return self
    }
}

#if DEBUG
// MARK: - Debug helpers
extension Logger {
    public static func forceEnable() {
        Logger.shouldLog(true)
    }
}
#endif

// MARK: - Convenience
extension Logger {
    private static let bundleIdentifier: String = Bundle.main.bundleIdentifier?.uppercased() ?? "\(Logger.self)"
    private static var currentTime: String { Date().toString(with: .DateFormats.ddMMyyyyHHmm) }
    private static func item(title: String, value: Any) -> String { "| 🔸 \(title): \(value)" }
    private static func underscores(_ count: Int) -> String { String(repeating: "_", count: count) }
}
