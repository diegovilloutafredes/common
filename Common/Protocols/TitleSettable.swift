//
//  TitleSettable.swift
//

import UIKit

// MARK: - TitleSettable
// MARK: - TitleSettable
/// A protocol for objects that can have a title string set.
public protocol TitleSettable: AnyObject {
    
    /// Sets the title of the object.
    /// - Parameter title: The title string to set.
    func set(title: String)
}

// MARK: - where Self: UIViewController
extension TitleSettable where Self: UIViewController {
    public func set(title: String) {
        (navigationItem.titleView as? UILabel)?.adjustsFontSizeToFitWidth(true)
        self.title = title
    }
}
