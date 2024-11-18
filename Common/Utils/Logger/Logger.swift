//
//  Logger.swift
//

import Foundation

// MARK: - Loggable
public protocol Loggable: Keyable {
    static var shouldLog: Bool { get }
}

// MARK: - Default implementation
extension Loggable {
    private static var store: KeyValueStore { .init() }
    public static var shouldLog: Bool {
        get { store.get(using: "\(staticKey).shouldLog") ?? true }
        set { store.add(item: (key: "\(staticKey).shouldLog", value: newValue)) }
    }
}

// MARK: - Logger
public enum Logger {
    public static func log(caller: String = #function, _ item: Any) { log(caller: caller, ["value": item]) }

    public static func log(caller: String = #function, _ request: URLRequest, data: Data? = nil, response: URLResponse?) {
        let httpResponse = response as? HTTPURLResponse

        guard let statusCode = httpResponse?.statusCode else { return }

        let url = request.url!
        let httpMethod = request.httpMethod!
        let httpBody = request.httpBody ?? Data()
        let body = String(data: httpBody, encoding: .utf8) ?? "Body is not a String"
        let headers = request.allHTTPHeaderFields
        let headersString = headers!.isEmpty ? "Empty headers" : "\(headers!)"

        log(
            caller: caller,
            [
                "STATUS CODE": statusCode,
                "URL": url,
                "HEADERS": headersString,
                "METHOD": httpMethod,
                "DATA": data?.toString() ?? .empty,
                "BODY": body
            ]
        )
    }

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
    private static var bundleIdentifier: String { Bundle.main.bundleIdentifier?.localizedUppercase ?? "\(self)" }
    private static var currentTime: String { Date().toString(with: .DateFormats.ddMMyyyyHHmm) }
    private static func item(title: String, value: Any) -> String { "| 🔸 \(title): \(value)" }
    private static func underscores(_ count: Int) -> String { Array(repeating: "_", count: count).joined() }
}
