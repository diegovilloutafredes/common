//
//  UICollectionReusableView+ReuseIdentifier.swift
//

import UIKit

extension UICollectionReusableView {
    public static var reuseIdentifier: String { .init(describing: self) }
}
