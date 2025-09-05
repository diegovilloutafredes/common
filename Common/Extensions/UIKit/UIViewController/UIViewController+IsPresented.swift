//
//  UIViewController+IsPresented.swift
//

import UIKit

extension UIViewController {
    public var isPresented: Bool { presentingViewController.isNotNil }
}
