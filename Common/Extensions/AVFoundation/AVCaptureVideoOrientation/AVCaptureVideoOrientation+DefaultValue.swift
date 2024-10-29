//
//  AVCaptureVideoOrientation+DefaultValue.swift
//

import AVFoundation
import UIKit

extension AVCaptureVideoOrientation {
    static var defaultValue: Self { UIDevice.current.orientation.forVideoOrientation }
}
