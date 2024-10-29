//
//  Data+HexEncodedString.swift
//

import Foundation

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    func hexEncodedString(options: HexEncodingOptions = []) -> String {
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
