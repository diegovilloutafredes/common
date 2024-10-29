//
//  String+AsMutableAttributedString.swift
//

import Foundation

extension String {
    public var asMutableAttributedString: NSMutableAttributedString { .init(string: self) }
    public func asMutableAttributedString(_ attributes: [NSAttributedString.Key: Any]) -> NSMutableAttributedString { .init(string: self, attributes: attributes) }
}
