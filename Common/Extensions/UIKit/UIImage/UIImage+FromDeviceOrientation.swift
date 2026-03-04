//
//  UIImage+FromDeviceOrientation.swift
//

import UIKit

extension UIImage {
    
    /// Returns the image orientation based on the current device orientation.
    public var fromDeviceOrientation: Orientation { .fromDeviceOrientation }
}

extension UIImage.Orientation {
    
    /// Returns the image orientation corresponding to the current device orientation.
    public static var fromDeviceOrientation: Self {
        switch UIDevice.current.orientation {
        case .portrait: .up
        case .landscapeLeft: .left
        case .landscapeRight: .right
        default: .up
        }
    }
}
