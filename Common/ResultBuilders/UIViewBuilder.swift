//
//  UIViewBuilder.swift
//

import UIKit

@resultBuilder
public struct UIViewBuilder {
    public static func buildBlock(_ components: UIView...) -> UIView { .init { components } }
}
