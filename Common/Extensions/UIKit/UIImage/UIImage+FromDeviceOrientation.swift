//
//  UIImage+FromDeviceOrientation.swift
//

import UIKit

extension UIImage {
    var fromDeviceOrientation: Orientation { .fromDeviceOrientation }
}

extension UIImage.Orientation {
    static var fromDeviceOrientation: Self {
        switch UIDevice.current.orientation {
        case .portrait: .up
        case .landscapeLeft: .left
        case .landscapeRight: .right
        default: .up
        }
    }
}
