//
//  String+AsUIColorFromHex.swift
//

import UIKit

extension String {
    
    /// Creates a UIColor from the hex string.
    public var asUIColorFromHex: UIColor { .init(hex: self) }
}
