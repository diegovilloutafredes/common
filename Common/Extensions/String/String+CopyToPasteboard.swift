//
//  String+CopyToPasteboard.swift
//

import UIKit

// MARK: - Copy To Pasteboard
extension String {
    public func copyToPasteboard() { UIPasteboard.general.string = self }
}
