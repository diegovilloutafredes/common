//
//  UIDeviceOrientation+ForVideoOrientation.swift
//

import AVFoundation
import UIKit

extension UIDeviceOrientation {
    public var forVideoOrientation: AVCaptureVideoOrientation {
        switch self {
        case .landscapeLeft: .landscapeRight
        case .landscapeRight: .landscapeLeft
        case .faceUp, .portrait: .portrait
        case .faceDown, .portraitUpsideDown: .portraitUpsideDown
        case .unknown: .portrait
        @unknown default: .portrait
        }
    }
}
