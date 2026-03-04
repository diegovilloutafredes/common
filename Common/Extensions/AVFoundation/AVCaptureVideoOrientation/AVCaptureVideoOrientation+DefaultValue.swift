//
//  AVCaptureVideoOrientation+DefaultValue.swift
//

import AVFoundation
import UIKit

extension AVCaptureVideoOrientation {
    
    /// Returns the default video orientation based on the current device orientation.
    static var defaultValue: Self { UIDevice.current.orientation.forVideoOrientation }
}
