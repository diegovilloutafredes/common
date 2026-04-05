//
//  UIViewController+Vibrate.swift
//

import AudioToolbox
import UIKit

/// A protocol for types that can trigger haptic vibration.
public protocol Vibrator: AnyObject {
    /// Triggers a vibration.
    func vibrate()
}

extension Vibrator {
    /// Default implementation that plays system vibration sound.
    public func vibrate() { AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate)) }
}

/// Makes UIViewController conform to the Vibrator protocol.
extension UIViewController: Vibrator {}
