//
//  ScreenSizeMeasurable.swift
//

import UIKit

// MARK: - ScreenSizeMeasurable
public protocol ScreenSizeMeasurable: AnyObject {
    var screenHeight: Double { get }
    var screenWidth: Double { get }
}

// MARK: - Default Implementation
extension ScreenSizeMeasurable {
    public var screenHeight: Double { .init(UIScreen.main.bounds.height) }
    public var screenWidth: Double { .init(UIScreen.main.bounds.width) }
}
