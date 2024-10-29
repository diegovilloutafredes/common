//
//  UIViewBuildable.swift
//

import UIKit

// MARK: - UIViewBuildable
public protocol UIViewBuildable {
    @UIViewBuilder var mainView: UIView { get }
}
