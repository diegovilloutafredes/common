//
//  String+CopyToPasteboard.swift
//

import UIKit

// MARK: - Copy To Pasteboard
// MARK: - Copy To Pasteboard
extension String {
    
    /// Copies the string to the general pasteboard.
    public func copyToPasteboard() { UIPasteboard.general.string = self }
}
