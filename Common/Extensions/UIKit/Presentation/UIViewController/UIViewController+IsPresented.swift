//
//  UIViewController+IsPresented.swift
//

import UIKit

extension UIViewController {
    
    /// Returns `true` if this view controller is being presented.
    public var isPresented: Bool { presentingViewController.isNotNil }
}
