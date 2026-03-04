//
//  ScreenSizeMeasurable.swift
//

import UIKit

// MARK: - ScreenSizeMeasurable
// MARK: - ScreenSizeMeasurable
/// A protocol for objects that can provide screen size measurements.
public protocol ScreenSizeMeasurable: AnyObject {
    
    /// The height of the screen.
    var screenHeight: Double { get }
    
    /// The width of the screen.
    var screenWidth: Double { get }
}

// MARK: - Default Implementation
extension ScreenSizeMeasurable {
    public var screenHeight: Double { .init(UIScreen.main.bounds.height) }
    public var screenWidth: Double { .init(UIScreen.main.bounds.width) }
}
