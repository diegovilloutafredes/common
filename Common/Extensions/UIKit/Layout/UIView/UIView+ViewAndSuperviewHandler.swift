//
//  UIView+ViewAndSuperviewHandler.swift
//

import UIKit

// MARK: - ViewAndSuperviewHandler
extension UIView {
    
    /// A handler type that receives both the view and its superview.
    public typealias ViewAndSuperviewHandler = Handler<(view: UIView, superview: UIView)>
}
