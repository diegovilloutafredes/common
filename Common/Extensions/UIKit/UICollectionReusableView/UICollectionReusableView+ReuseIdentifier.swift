//
//  UICollectionReusableView+ReuseIdentifier.swift
//

import UIKit

extension UICollectionReusableView {
    
    /// Returns a reusable identifier string based on the class name.
    public static var reuseIdentifier: String { .init(describing: self) }
}
