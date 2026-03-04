//
//  Data+HexEncodedString.swift
//

import Foundation

extension Data {
    
    /// Options for hex encoding.
    public struct HexEncodingOptions: OptionSet {
        public let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }

    /// Returns a hexadecimal encoded string representation of the data.
    /// - Parameter options: Encoding options (e.g., `.upperCase`).
    /// - Returns: The hex encoded string.
    public func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let hexDigits = Array((options.contains(.upperCase) ? "0123456789ABCDEF" : "0123456789abcdef").utf16)
        var chars = [unichar]()

        chars.reserveCapacity(2 * count)

        forEach {
            chars.append(hexDigits[Int($0 / 16)])
            chars.append(hexDigits[Int($0 % 16)])
        }

        return .init(utf16CodeUnits: chars, count: chars.count)
    }
}
