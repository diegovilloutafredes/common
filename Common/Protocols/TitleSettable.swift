//
//  TitleSettable.swift
//

import UIKit

// MARK: - TitleSettable
public protocol TitleSettable: AnyObject {
    func set(title: String)
}

// MARK: - where Self: UIViewController
extension TitleSettable where Self: UIViewController {
    public func set(title: String) {
        (navigationItem.titleView as? UILabel)?.adjustsFontSizeToFitWidth(true)
        self.title = title
    }
}
