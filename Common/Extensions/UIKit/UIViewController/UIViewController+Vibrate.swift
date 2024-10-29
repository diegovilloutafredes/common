//
//  UIViewController+Vibrate.swift
//

import AudioToolbox
import UIKit

public protocol Vibrator: AnyObject {
    func vibrate()
}

extension Vibrator {
    public func vibrate() { AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate)) }
}

extension UIViewController: Vibrator {}
